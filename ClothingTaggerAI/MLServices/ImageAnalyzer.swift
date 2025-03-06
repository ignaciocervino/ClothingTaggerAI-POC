//
//  ImageAnalyzer.swift
//  ClothingTaggerAI
//
//  Created by Ignacio Cervino on 04/03/2025.
//

import Foundation
import OSLog
import SwiftUI

final class ImageAnalysis {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.ClothingTaggerAI",
        category: "ImageAnalysisService")

    private let vlmService: VLMServiceProtocol

    init(vlmService: VLMServiceProtocol) {
        self.vlmService = vlmService
    }

    func analyze(image: UIImage, prompt: String? = nil) async -> String? {
        logger.info("Starting image analysis process")
        logger.debug(
            "Image dimensions: \(image.size.width)x\(image.size.height)")

        do {
            logger.debug("Sending image for VLM analysis")
            let analysisStartTime = Date()

            let result = try await vlmService.analyze(image: image, prompt: prompt)

            let duration = Date().timeIntervalSince(analysisStartTime)
            logger.info("Analysis completed in \(String(format: "%.2f", duration)) seconds")

            return result
        } catch {
            logger.error("Analysis failed: \(error.localizedDescription)")
            return nil
        }
    }

    func reset() {
        logger.info("Resetting analysis service and VLM service")
        vlmService.reset()
    }
}

