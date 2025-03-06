//
//  Logger+Configuration.swift
//  ClothingTaggerAI
//
//  Created by Ignacio Cervino on 06/03/2025.
//

import OSLog

extension Logger {
    private static var subsystem: String { Bundle.main.bundleIdentifier! }

    static let modelLoader = Logger(subsystem: subsystem, category: "MLXModelLoader")
    static let imageAnalysis = Logger(subsystem: subsystem, category: "ImageAnalysis")
    static let vlmService = Logger(subsystem: subsystem, category: "VLMService")
    static let photoProcessing = Logger(subsystem: subsystem, category: "PhotoProcessing")
    static let viewEvents = Logger(subsystem: subsystem, category: "ViewEvents")
}
