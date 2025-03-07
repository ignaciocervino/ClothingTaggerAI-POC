//
//  ImageAnalyzer.swift
//  ClothingTaggerAI
//
//  Created by Ignacio Cervino on 04/03/2025.
//

import OSLog
import SwiftUI

final class ClothingTaggerService {
    private let logger = Logger.clothingTagger

    private let vlmService: VLMServiceProtocol
    private let prompt = """
    You are ClosetAI, a fashion-savvy image classifier.  
    - Describe detected clothing uniquely in exactly four words (e.g., 'Denim Jacket Blue Wash').
    - Use only letters, no commas, punctuation marks or special symbols.
    - The first word **must** be the clothing type.
    - The second word **must** describe fabric or pattern.
    - The third word **must** describe the color.
    - The fourth word **must** be another defining characteristic.
    - If no clothing is detected, reply strictly 'null'.
    """

    init(vlmService: VLMServiceProtocol) {
        self.vlmService = vlmService
    }

    func tagClothing(in image: UIImage) async -> String? {
        logger.info("Starting clothing tagging process")
        logger.debug("Image dimensions: \(image.size.width)x\(image.size.height)")

        do {
            let analysisStartTime = Date()

            let result = try await vlmService.analyze(image: image, prompt: prompt)

            let duration = Date().timeIntervalSince(analysisStartTime)
            logger.info("Tagging completed in \(String(format: "%.2f", duration)) seconds")

            return result
        } catch {
            logger.error("Tagging failed with: \(error.localizedDescription), returning nil")
            return nil
        }
    }

    func reset() {
        vlmService.reset()
    }
}
