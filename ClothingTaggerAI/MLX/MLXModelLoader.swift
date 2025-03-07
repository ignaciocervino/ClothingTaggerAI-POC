//
//  MLXModelLoader.swift
//  ClothingTaggerAI
//
//  Created by Ignacio Cervino on 04/03/2025.
//

import Foundation
import MLX
import MLXLMCommon
import MLXVLM
import MLXRandom
import OSLog
import SwiftUI

enum MLXModelLoaderError: Error {
    case analysisAlreadyInProgress
    case failedWith(description: String)
    case taskCancelled
}

@Observable
@MainActor
final class MLXModelLoader {
    enum ModelLoadState {
        case idle
        case loaded(ModelContainer)
    }

    private let logger = Logger.modelLoader
    private var running = false
    var loadState: ModelLoadState = .idle

    let modelConfiguration = ModelRegistry.qwen2VL2BInstruct4Bit
    let generateParameters = MLXLMCommon.GenerateParameters(temperature: 0.6)
    let maxTokens = 800

    /// Load and return the model (ensures it's loaded before inference)
    func load() async throws -> ModelContainer {
        switch loadState {
        case .idle:
            logger.info("🚀 Starting model load process...")

            MLX.GPU.set(cacheLimit: 20 * 1024 * 1024)

            let modelContainer = try await VLMModelFactory.shared.loadContainer(
                configuration: modelConfiguration
            )

            let numParams = await modelContainer.perform { context in
                context.model.numParameters()
            }

            loadState = .loaded(modelContainer)
            logger.info("✅ Model loaded successfully with \(numParams) parameters")

            return modelContainer

        case .loaded(let modelContainer):
            return modelContainer
        }
    }

    func analyze(image: CIImage, prompt: String) async throws -> String {
        logger.info("Starting image analysis")

        guard !running else {
            logger.warning("Analysis already in progress, skipping request")
            throw MLXModelLoaderError.analysisAlreadyInProgress
        }

        running = true
        defer { running = false }

        do {
            logger.debug("📥 Loading model for analysis")
            let modelContainer = try await load()

            try Task.checkCancellation()

            logger.debug("🎲 Setting random seed for inference")
            MLXRandom.seed(UInt64(Date.timeIntervalSinceReferenceDate * 1000))

            let startTime = Date()
            logger.info("🚀 Starting model inference")

            let result = try await modelContainer.perform { context in
                try Task.checkCancellation()

                let images: [UserInput.Image] = [UserInput.Image.ciImage(image)]

                let messages: [Message] = [
                    [
                        "role": "system",
                        "content": [["type": "text", "text": prompt]]
                    ],
                    [
                        "role": "user",
                        "content": [["type": "image"]]
                    ]
                ]

                logger.debug("🔍 Preparing user input for inference")
                let userInput = UserInput(messages: messages, images: images, videos: [])
                let input = try await context.processor.prepare(input: userInput)

                try Task.checkCancellation()

                logger.debug("💬 Starting token generation")
                return try MLXLMCommon.generate(
                    input: input,
                    parameters: generateParameters,
                    context: context
                ) { [weak self] tokens in
                    guard let self else { return .stop }
                    if Task.isCancelled { return .stop }
                    return tokens.count >= maxTokens ? .stop : .more
                }
            }

            let duration = Date().timeIntervalSince(startTime)
            logger.info("✅ Inference completed in \(String(format: "%.2f", duration)) seconds")

            return result.output

        } catch is CancellationError {
            logger.info("⚠️ Analysis was cancelled")
            throw MLXModelLoaderError.taskCancelled
        } catch {
            logger.error("❌ Analysis failed: \(error.localizedDescription)")
            throw MLXModelLoaderError.failedWith(description: error.localizedDescription)
        }
    }

    /// Resets model state
    func reset() {
        logger.info("🔄 Resetting model loader")

        running = false
        loadState = .idle

        MLX.GPU.clearCache()
        logger.debug("🧹 Cleared GPU cache")
    }
}
