//
//  ModelLoader.swift
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

@Observable
@MainActor
final class MLXModelLoader {
    enum ModelLoadState {
        case idle
        case loaded(ModelContainer)
    }

    private let logger = Logger.modelLoader
    var loadState: ModelLoadState = .idle
    var running = false

    /// Updated model based on VLMEvaluator
    let modelConfiguration = ModelRegistry.qwen2VL2BInstruct4Bit

    /// Updated generation parameters from VLMEvaluator
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

    private var analysisTask: Task<String, Error>?
    var output = ""
    let systemPrompt = """
    You are a strict clothing identification AI.
    - If the image contains clothing, respond with the name of the clothing in **three words or fewer**.
    - If no clothing is detected, respond **only** with 'nil'.
    - Do **not** provide additional text, explanations, or symbols.
    """

    func analyze(image: UIImage, prompt: String? = nil) async throws -> String {
        logger.info("Starting image analysis")

        guard !running else {
            logger.warning("Analysis already in progress, skipping request")
            return ""
        }

        guard
            let smallImage = image.resized(
                to: CGSize(width: 1024, height: 1024))
        else {
            return ""
        }

        running = true
        output = ""

        analysisTask = Task {
            do {
                logger.debug("Loading model for analysis")
                let modelContainer = try await load()

                guard let ciImage = CIImage(image: smallImage) else {
                    logger.error("Failed to convert UIImage to CIImage")
                    throw NSError(
                        domain: "ModelLoader", code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Failed to convert image"
                        ])
                }

                try Task.checkCancellation()

                logger.debug("Setting random seed for inference")
                MLXRandom.seed(
                    UInt64(Date.timeIntervalSinceReferenceDate * 1000))

                let startTime = Date()
                logger.info("Starting model inference")

                let defaultPrompt =
                    "Identify the clothing in this image using three words or fewer. If no clothing is present, return 'nil' only."
                let result = try await modelContainer.perform { context in
                    try Task.checkCancellation()

                    let images: [UserInput.Image] = [
                        UserInput.Image.ciImage(ciImage)
                    ]

                    let messages: [Message] = [
                        [
                            "role": "system",
                            "content": [
                                [
                                    "type": "text",
                                    "text": systemPrompt,
                                ]
                            ],
                        ],
                        [
                            "role": "user",
                            "content": [
                                ["type": "image"],
                                [
                                    "type": "text",
                                    "text": defaultPrompt,
                                ],
                            ],
                        ],
                    ]

                    logger.debug("Preparing user input for inference")
                    let userInput = UserInput(
                        messages: messages, images: images, videos: [])
                    let input = try await context.processor.prepare(
                        input: userInput)

                    try Task.checkCancellation()

                    logger.debug("Starting token generation")
                    return try MLXLMCommon.generate(
                        input: input,
                        parameters: generateParameters,
                        context: context
                    ) { [weak self] tokens in
                        guard let self else { return .stop }

                        if Task.isCancelled {
                            return .stop
                        }

                        if tokens.count >= maxTokens {
                            logger.debug(
                                "Reached maximum token count: \(self.maxTokens)"
                            )
                            return .stop
                        } else {
                            return .more
                        }
                    }
                }

                let duration = Date().timeIntervalSince(startTime)
                logger.info(
                    "Inference completed in \(String(format: "%.2f", duration)) seconds"
                )

                return result.output

            } catch is CancellationError {
                logger.info("Analysis was cancelled")
                return ""
            } catch {
                logger.error("Analysis failed: \(error.localizedDescription)")
                throw error
            }
        }

        do {
            let result = try await analysisTask?.value ?? ""
            running = false
            return result
        } catch {
            running = false
            throw error
        }
    }

    /// Cleans and processes model output
    private func processModelOutput(_ output: String) -> String {
        logger.debug("📌 Processing raw model output: '\(output)'")

        let cleanedOutput = output
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "[^a-zA-Z0-9\\s]", with: "", options: .regularExpression) // ✅ Remove special characters

        logger.debug("🔍 Cleaned output: '\(cleanedOutput)'")

        let words = cleanedOutput.split(separator: " ").map { String($0) }

        let finalOutput: String
        if cleanedOutput.lowercased() == "nil" || words.isEmpty {
            finalOutput = "nil"
        } else if words.count > 3 {
            finalOutput = words.prefix(3).joined(separator: " ")
        } else {
            finalOutput = cleanedOutput
        }

        logger.info("✅ Final cleaned result: '\(finalOutput)'")
        return finalOutput
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
