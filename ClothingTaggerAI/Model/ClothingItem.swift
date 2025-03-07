//
//  ClothingItem.swift
//  ClothingTaggerAI
//
//  Created by Ignacio Cervino on 07/03/2025.
//

import SwiftUI

struct ClothingItem: Identifiable {
    let id = UUID()
    let uiImage: UIImage?
    var tag: String
}
