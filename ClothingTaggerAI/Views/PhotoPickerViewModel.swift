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
    private let imageAnalyzer: ImageAnalysis

    var selectedImage: UIImage? = nil
    var detectedClothing: String? = nil
    @Published var isProcessing: Bool = false

    var imageSelection: PhotosPickerItem? = nil {
        didSet {
            Task { await loadImage(from: imageSelection) }
        }
    }

    init(model: MLXModelLoader) {
        let vlmService = VLMService(modelLoader: model)
        self.imageAnalyzer = ImageAnalysis(vlmService: vlmService)
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
    func analyze(image: UIImage) async -> String? {
        isProcessing = true
        detectedClothing = nil

        let prompt = """
        1. Check if the image contains a clothing item.
        2. If yes, return the clothing type in at most 3 words.
        3. If not, return 'nil'.
        """

        let result = await imageAnalyzer.analyze(image: image, prompt: prompt)

        self.detectedClothing = result
        self.isProcessing = false

        return result
    }
}
