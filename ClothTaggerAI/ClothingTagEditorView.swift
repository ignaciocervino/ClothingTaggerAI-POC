//
//  ClothingTagEditorView.swift
//  ClothTaggerAI
//
//  Created by Ignacio Cervino on 03/03/2025.
//

import SwiftUI

struct ClothingTagEditorView: View {
    @Binding var clothingItem: ClothingItem
    @FocusState private var isEditing: Bool
    var onDelete: () -> Void

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                Image(uiImage: clothingItem.uiImage ?? .tshirtAddIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .cornerRadius(12)
                    .shadow(radius: 4)

                TextField("Item name", text: $clothingItem.tag)
                    .font(.title2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .textFieldStyle(PlainTextFieldStyle())
                    .focused($isEditing)

            }
            .padding()
            .frame(width: 260)
            .background(.thinMaterial)
            .cornerRadius(16)
            .shadow(radius: 5)
            .onAppear {
                isEditing = true
            }
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
        clothingItem: .constant(ClothingItem(uiImage: .tshirtAddIcon, tag: "Blue Shirt")),
        onDelete: {}
    )
}
