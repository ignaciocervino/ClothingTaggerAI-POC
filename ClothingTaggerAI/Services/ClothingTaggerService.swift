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
    let prompt = """
    You are an expert clothing classification AI.
    - If the image contains clothing, describe it with **a short but detailed name** (e.g., "Green Cotton Pant", "Red Floral Dress").
    - Your response must be **concise** (max 4 words) but include **color, pattern, or material** if visible.
    - If no clothing is detected, respond **only** with 'null'.
    - Do **not** add extra explanations, symbols, or text.
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
