//
//  HomeView.swift
//  ClothingTaggerAI
//
//  Created by Ignacio Cervino on 03/03/2025.
//

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
    @State private var showPopup = false

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
                    let detectedClothing = await photoPickerViewModel.analyze(image: newImage)
                    let newClothing = ClothingItem(uiImage: newImage, tag: detectedClothing ?? "Unknown")

                    DispatchQueue.main.async {
                        clothes.append(newClothing)
                    }
                }
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
                            showPopup = true
                        }
                }
            }
            .padding()
        }
    }

    private var backgroundOverlay: some View {
        Color.black.opacity(showPopup ? 0.9 : 0)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture { showPopup = false }
            .animation(.easeInOut, value: showPopup)
            .allowsHitTesting(showPopup)
    }

    private var popupView: some View {
        Group {
            if showPopup, let selectedId = selectedItemId,
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
                        clothes.removeAll { $0.id == selectedId }
                        selectedItemId = nil
                        showPopup = false
                    }
                )
                .opacity(showPopup ? 1 : 0)
                .scaleEffect(showPopup ? 1 : 0.8)
                .allowsHitTesting(showPopup)
            }
        }
    }
}

#Preview {
    HomeView()
}
