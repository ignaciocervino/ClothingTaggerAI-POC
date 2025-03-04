//
//  PhotoPickerViewModel.swift
//  ClothingTaggerAI
//
//  Created by Ignacio Cervino on 03/03/2025.
//

import SwiftUI
import PhotosUI

@MainActor
@Observable
final class PhotoPickerViewModel  {
    var selectedImage: UIImage? = nil
    var imageSelection: PhotosPickerItem? = nil {
        didSet {
            loadImage(from: imageSelection)
        }
    }

    private func loadImage(from selection: PhotosPickerItem?) {
        guard let selection else { return }

        Task {
            if let imageData = try? await selection.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: imageData) {
                self.selectedImage = uiImage
            }
        }
    }
}
