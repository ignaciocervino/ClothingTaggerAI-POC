//
//  ClothingTagEditorView.swift
//  ClothTaggerAI
//
//  Created by Ignacio Cervino on 03/03/2025.
//

import SwiftUI

struct ClothingTagEditorView: View {
    let clothingItem: ClothingItem
    var onDelete: () -> Void
    @State private var editedTag: String
    @State private var isEditing = false

    init(clothingItem: ClothingItem, onDelete: @escaping () -> Void) {
        self.clothingItem = clothingItem
        self.onDelete = onDelete
        self._editedTag = State(initialValue: clothingItem.tag)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                Image(uiImage: clothingItem.uiImage ?? .tshirtAddIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .cornerRadius(12)

                HStack {
                    if isEditing {
                        TextField("", text: $editedTag)
                    } else {
                        Text(editedTag)
                            .font(.title2)
                            .fontWeight(.medium)
                    }

                    Button(action: { isEditing.toggle() }) {
                        Image(systemName: isEditing ? "checkmark" : "pencil")
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .frame(width: 250)
            .background(.thinMaterial)
            .cornerRadius(16)
            .shadow(radius: 5)
            .overlay(
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.8))
                        )
                }
                .offset(x: 10, y: -10)
                .zIndex(1),
                alignment: .topTrailing
            )
        }
    }
}

#Preview {
    ClothingTagEditorView(
        clothingItem: ClothingItem(uiImage: .tshirtAddIcon, tag: "Blue Shirt"),
        onDelete: {}
    )
}
