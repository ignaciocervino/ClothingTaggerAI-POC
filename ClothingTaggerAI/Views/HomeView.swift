//
//  HomeView.swift
//  ClothingTaggerAI
//
//  Created by Ignacio Cervino on 03/03/2025.
//

import OSLog
import SwiftUI
import PhotosUI

struct ClothingItem: Identifiable {
    let id = UUID()
    let uiImage: UIImage?
    var tag: String
}

let mockClothes: [ClothingItem] = [
    ClothingItem(uiImage: .tshirtAddIcon, tag: "Blue Shirt"),
    ClothingItem(uiImage: .tshirtAddIcon, tag: "Blue Shirt"),
    ClothingItem(uiImage: .tshirtAddIcon, tag: "Blue Shirt"),
    ClothingItem(uiImage: .tshirtAddIcon, tag: "Blue Shirt")
]

struct HomeView: View {
    @StateObject private var photoPickerViewModel: PhotoPickerViewModel
    @State private var clothes = mockClothes
    @State private var selectedItemId: UUID?
    @State private var showClothingItemPopup = false
    private let logger = Logger.viewEvents

    init() {
        _photoPickerViewModel = StateObject(
            wrappedValue: PhotoPickerViewModel(model: MLXModelLoader()))
    }

    var body: some View {
        ZStack {
            mainContentView
            backgroundOverlay
            popupView
        }
    }

    private var mainContentView: some View {
        NavigationStack {
            VStack {
                if clothes.isEmpty {
                    Text("No clothes added yet.").foregroundColor(.gray)
                } else {
                    clothesGridView
                }
            }
            .navigationTitle("My Closet")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    PhotosPicker(selection: $photoPickerViewModel.imageSelection, matching: .images) {
                        Image(systemName: "plus.circle.fill").font(.title)
                    }
                }
            }
            .overlay {
                if photoPickerViewModel.isProcessing {
                    VStack {
                        ProgressView("Analyzing image...")
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.4))
                }
            }
            .onChange(of: photoPickerViewModel.selectedImage) { _, newImage in
                guard let newImage else { return }
                Task {
                    let newClothingItem = await photoPickerViewModel.tagClothing(in: newImage)

                    await MainActor.run {
                        if let newClothingItem {
                            logger.info("Appended \(newClothingItem.tag) to the list.")
                            clothes.append(newClothingItem)
                        }
                    }
                }
            }
            .alert(item: $photoPickerViewModel.clothingError) { error in
                Alert(title: Text(error.errorType.rawValue.capitalized), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    private var clothesGridView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 16) {
                ForEach(clothes) { item in
                    ClothingItemView(item: item)
                        .onTapGesture {
                            selectedItemId = item.id
                            showClothingItemPopup = true
                        }
                }
            }
            .padding()
        }
    }

    private var backgroundOverlay: some View {
        Color.black.opacity(showClothingItemPopup ? 0.9 : 0)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture { showClothingItemPopup = false }
            .animation(.easeInOut, value: showClothingItemPopup)
            .allowsHitTesting(showClothingItemPopup)
    }

    private var popupView: some View {
        Group {
            if showClothingItemPopup, let selectedId = selectedItemId,
               let selectedItem = clothes.first(where: { $0.id == selectedId }) {
                ClothingTagEditorView(
                    clothingItem: Binding(
                        get: { selectedItem },
                        set: { newValue in
                            if let index = clothes.firstIndex(where: { $0.id == selectedId }) {
                                clothes[index] = newValue
                            }
                        }
                    ),
                    onDelete: {
                        logger.info("Removing clothing item with id \(selectedId)")
                        clothes.removeAll { $0.id == selectedId }
                        selectedItemId = nil
                        showClothingItemPopup = false
                    }
                )
                .opacity(showClothingItemPopup ? 1 : 0)
                .scaleEffect(showClothingItemPopup ? 1 : 0.8)
                .allowsHitTesting(showClothingItemPopup)
            }
        }
    }
}

#Preview {
    HomeView()
}
