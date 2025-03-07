//
//  PhotoPickerViewModel.swift
//  ClothingTaggerAI
//
//  Created by Ignacio Cervino on 03/03/2025.
//

import OSLog
import SwiftUI
import PhotosUI

struct TagError: Identifiable {
    var id = UUID()
    var errorType: ErrorType
    var message: String

    enum ErrorType: String {
        case error = "Error"
        case warning = "Warning"
    }
}

final class PhotoPickerViewModel: ObservableObject {
    private let logger = Logger.viewEvents
    private let clothingAnalyzer: ClothingTaggerService

    var selectedImage: UIImage? = nil
    @Published var closetItems: [ClothingItem] = []
    @Published var isProcessing: Bool = false
    @Published var clothingError: TagError? = nil

    var imageSelection: PhotosPickerItem? = nil {
        didSet {
            Task { await loadImage(from: imageSelection) }
        }
    }

    init(model: MLXModelLoader) {
        let vlmService = VLMService(modelLoader: model)
        self.clothingAnalyzer = ClothingTaggerService(vlmService: vlmService)
    }

    @MainActor
    private func loadImage(from selection: PhotosPickerItem?) async {
        guard let selection else { return }

        isProcessing = true

        do {
            if let imageData = try await selection.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: imageData) {
                await MainActor.run { self.selectedImage = uiImage }
            }
        } catch {
            logger.error("❌ Failed to load image: \(error.localizedDescription)")
            clothingError = TagError(errorType: .error, message: "Failed to load image.")
        }

        isProcessing = false
    }

    @MainActor
    func tagClothing(in image: UIImage) async {
        isProcessing = true
        let clothingTag = await clothingAnalyzer.tagClothing(in: image)
        isProcessing = false

        guard let clothingTag else {
            clothingError = TagError(errorType: .error, message: "Something went wrong while analyzing the image.")
            return
        }

        if clothingTag.lowercased() == "null" {
            logger.warning("⚠️ Image does not contain a recognized clothing item.")
            clothingError = TagError(errorType: .warning, message: "The image does not appear to be a clothing item.")
        } else {
            closetItems.append(ClothingItem(uiImage: image, tag: clothingTag))
            logger.info("Adding \(clothingTag) to the closet.")
        }
    }

    func removeClothingItem(item: ClothingItem) {
        closetItems.removeAll { $0.id == item.id }
    }
}
