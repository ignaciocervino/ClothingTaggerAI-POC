//
//  ImageAnalyzer.swift
//  ClothingTaggerAI
//
//  Created by Ignacio Cervino on 04/03/2025.
//

import Foundation
import OSLog
import SwiftUI

final class ClothingTaggerService {
    private let logger = Logger.clothingTagger

    private let vlmService: VLMServiceProtocol
    let prompt = """
        1. Check if the image contains a clothing item.
        2. If yes, return the clothing type in at most 3 words.
        3. If not, return 'nil'.
        """

    init(vlmService: VLMServiceProtocol) {
        self.vlmService = vlmService
    }

    func tagClothing(in image: UIImage) async -> String? {
        logger.info("Starting clothing tagging process")
        logger.debug("Image dimensions: \(image.size.width)x\(image.size.height)")

        do {
            logger.debug("Sending image for VLM analysis")
            let analysisStartTime = Date()

            let result = try await vlmService.analyze(image: image, prompt: prompt)

            let duration = Date().timeIntervalSince(analysisStartTime)
            logger.info("Tagging completed in \(String(format: "%.2f", duration)) seconds")

            return result
        } catch {
            logger.error("Tagging failed with: \(error.localizedDescription)")
            return nil
        }
    }

    func reset() {
        vlmService.reset()
    }
}

// MARK: - Helpers
private extension ClothingTaggerService {
    func processResponse(_ response: String) -> String? {
        let lowercasedResponse = response.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        if lowercasedResponse == "nil" {
            return nil
        }

        let words = lowercasedResponse.split(separator: " ").prefix(3)
        return words.joined(separator: " ")
    }
}
