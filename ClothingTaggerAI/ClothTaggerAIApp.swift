//
//  ClothingTaggerAIApp.swift
//  ClothingTaggerAI
//
//  Created by Ignacio Cervino on 03/03/2025.
//

import SwiftUI

@main
struct ClothingTaggerAIApp: App {
    private let modelLoader = MLXModelLoader()
    @State private var showOnboarding: Bool = true

    var body: some Scene {
        WindowGroup {
            HomeView(model: modelLoader)
                .overlay {
                    if showOnboarding {
                        OnboardingView(showOnboarding: $showOnboarding)
                            .environment(modelLoader)
                    }
                }
                .animation(.easeInOut(duration: 0.5), value: showOnboarding)
        }
    }
}
