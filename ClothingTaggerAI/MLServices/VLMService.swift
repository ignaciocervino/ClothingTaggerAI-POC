//
//  VLMService.swift
//  ClothingTaggerAI
//
//  Created by Ignacio Cervino on 03/03/2025.
//

import SwiftUI
import OSLog

protocol VLMServiceProtocol {
    func analyze(image: UIImage, prompt: String?) async throws -> String
    func reset()
}

final class VLMService {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.ClothingTaggerAI",
        category: "MLXService"
    )
    private let modelLoader: MLXModelLoader

    init(modelLoader: MLXModelLoader) {
        self.modelLoader = modelLoader
    }

    // MARK: - Helpers
    private func processResponse(_ response: String) -> String? {
        let lowercasedResponse = response.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if lowercasedResponse == "nil" {
            return nil
        }

        let words = lowercasedResponse.split(separator: " ").prefix(3)
        return words.joined(separator: " ")
    }
}

extension VLMService: VLMServiceProtocol {
    func analyze(image: UIImage, prompt: String?) async throws -> String {
        logger.info("Starting VLM analysis")
        return try await modelLoader.analyze(image: image)
    }

    @MainActor func reset() {
        logger.info("Resetting VLMService")
        modelLoader.reset()
    }
}
