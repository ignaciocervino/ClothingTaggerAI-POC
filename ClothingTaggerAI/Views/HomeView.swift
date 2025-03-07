//
//  HomeView.swift
//  ClothingTaggerAI
//
//  Created by Ignacio Cervino on 03/03/2025.
//

import OSLog
import SwiftUI
import PhotosUI

struct HomeView: View {
    @StateObject private var viewModel: PhotoPickerViewModel
    @State private var selectedItem: ClothingItem?
    @State private var showClothingItemPopup = false
    private let logger = Logger.viewEvents

    init(model: MLXModelLoader) {
        _viewModel = StateObject(
            wrappedValue: PhotoPickerViewModel(model: model))
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
                if $viewModel.closetItems.isEmpty {
                    Text("No clothes added yet.").foregroundColor(.gray)
                } else {
                    clothesGridView
                }
            }
            .navigationTitle("My Closet")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    PhotosPicker(selection: $viewModel.imageSelection, matching: .images) {
                        Image(systemName: "plus.circle.fill").font(.title)
                    }
                }
            }
            .overlay {
                if viewModel.isProcessing {
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
            .onChange(of: viewModel.selectedImage) { _, newImage in
                guard let newImage else { return }
                Task {
                    await viewModel.tagClothing(in: newImage)
                }
            }
            .alert(item: $viewModel.clothingError) { error in
                Alert(title: Text(error.errorType.rawValue.capitalized), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    private var clothesGridView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 16) {
                ForEach(viewModel.closetItems) { item in
                    ClothingItemView(item: item)
                        .onTapGesture {
                            selectedItem = item
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
            if showClothingItemPopup, let selectedItem {
                ClothingTagEditorView(
                    clothingItem: Binding(
                        get: { selectedItem },
                        set: { newValue in
                            if let index = viewModel.closetItems.firstIndex(where: { $0.id == selectedItem.id }) {
                                viewModel.closetItems[index] = newValue
                            }
                        }
                    ),
                    onDelete: {
                        viewModel.removeClothingItem(item: selectedItem)
                        self.selectedItem = nil
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
    HomeView(model: MLXModelLoader())
}
