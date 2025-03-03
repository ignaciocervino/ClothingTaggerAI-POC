//
//  HomeView.swift
//  ClothTaggerAI
//
//  Created by Ignacio Cervino on 03/03/2025.
//

import SwiftUI

// Mock Data Model
struct ClothingItem: Identifiable {
    let id = UUID()
    let imageName: String
    var tag: String
}

// Mock Data
let mockClothes: [ClothingItem] = [
    ClothingItem(imageName: "tshirt.add.icon", tag: "Blue Shirt"),
    ClothingItem(imageName: "tshirt.add.icon", tag: "Black Jeans"),
    ClothingItem(imageName: "tshirt.add.icon", tag: "Winter Jacket"),
    ClothingItem(imageName: "tshirt.add.icon", tag: "Running Shoes")
]

struct HomeView: View {
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
                        Button(action: {
                            // Navigate to Photo Selection Screen
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                        }
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
