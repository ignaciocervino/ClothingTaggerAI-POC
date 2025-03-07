//
//  ClothingItemView.swift
//  ClothingTaggerAI
//
//  Created by Ignacio Cervino on 03/03/2025.
//

import SwiftUI

struct ClothingItemView: View {
    let item: ClothingItem

    var body: some View {
        VStack(spacing: 8) {
            Image(uiImage: item.uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipped()
                .cornerRadius(10)

            Text(item.tag)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

        }
        .frame(width: 140, height: 170)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}

#Preview {
    ClothingItemView(item: ClothingItem(uiImage: .tshirtAddIcon, tag: "Royal Blue Shirt"))
}
