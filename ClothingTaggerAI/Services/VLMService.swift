//
//  VLMService.swift
//  ClothingTaggerAI
//
//  Created by Ignacio Cervino on 03/03/2025.
//

import SwiftUI
import OSLog

protocol VLMServiceProtocol {
    func analyze(image: UIImage, prompt: String) async throws -> String
    func reset()
}

final class VLMService {
    private let logger = Logger.vlmService
    private let modelLoader: MLXModelLoader

    init(modelLoader: MLXModelLoader) {
        self.modelLoader = modelLoader
    }
}

extension VLMService: VLMServiceProtocol {
    func analyze(image: UIImage, prompt: String) async throws -> String {
        logger.info("Starting VLM analysis")
        guard let ciImage = CIImage(image: image) else {
            logger.error("❌ Failed to convert UIImage to CIImage")
            throw NSError(
                domain: "VLMService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to convert UIImage to CIImage"]
            )
        }
        return try await modelLoader.analyze(image: ciImage, prompt: prompt)
    }

    func reset() {
        logger.info("Resetting VLMService")
        Task { @MainActor in
            modelLoader.reset()
        }
    }
}
