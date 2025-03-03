//
//  HomeView.swift
//  ClothTaggerAI
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
    @State private var photoPickerViewModel = PhotoPickerViewModel()
    @State private var clothes = mockClothes
    @State private var selectedItem: ClothingItem?
    @State private var showPopup = false

    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    if clothes.isEmpty {
                        Text("No clothes added yet.")
                            .foregroundColor(.gray)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 16) {
                                ForEach(clothes.indices, id: \.self) { index in
                                    ClothingItemView(item: clothes[index])
                                        .onTapGesture {
                                            selectedItem = clothes[index]
                                            showPopup = true
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                }
                .navigationTitle("My Closet")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        PhotosPicker(selection: $photoPickerViewModel.imageSelection, matching: .images) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                        }
                    }
                }
                .onChange(of: photoPickerViewModel.selectedImage) { _, newImage in
                    if let newImage {
                        let newClothing = ClothingItem(uiImage: newImage, tag: "NewImage")
                        clothes.append(newClothing)
                    }
                }
            }

            if showPopup {
                Color.black.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showPopup = false
                    }
                    .zIndex(1)
            }

            if showPopup, let selectedItem = selectedItem {
                ClothingTagEditorView(
                    clothingItem: selectedItem,
                    onDelete: {
                        clothes.removeAll { $0.id == selectedItem.id }
                        showPopup = false
                    }
                )
                .transition(.scale)
                .zIndex(2)
            }
        }
    }
}

#Preview {
    HomeView()
}
