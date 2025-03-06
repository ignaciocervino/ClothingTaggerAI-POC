//
//  PhotoPickerViewModel.swift
//  ClothingTaggerAI
//
//  Created by Ignacio Cervino on 03/03/2025.
//

import SwiftUI
import PhotosUI
import OSLog

final class PhotoPickerViewModel: ObservableObject {
    private let clothingAnalyzer: ClothingTaggerService

    var selectedImage: UIImage? = nil
    @Published var isProcessing: Bool = false

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
            Logger.photoProcessing.error("❌ Failed to load image: \(error.localizedDescription)")
        }

        isProcessing = false
    }

    @MainActor
    func tagClothing(in image: UIImage) async -> String {
        isProcessing = true

        let tag = await clothingAnalyzer.tagClothing(in: image)

        self.isProcessing = false

        return tag ?? "Undefined"
    }
}
