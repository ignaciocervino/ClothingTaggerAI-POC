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

    var body: some View {
        NavigationStack {
            VStack {
                if clothes.isEmpty {
                    Text("No clothes added yet.")
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 16) {
                            ForEach(clothes) { item in
                                ClothingItemView(item: item)
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
                        Image("tshirt.add.icon")
                            .font(.title)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
