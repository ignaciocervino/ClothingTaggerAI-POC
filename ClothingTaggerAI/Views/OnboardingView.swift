//
//  OnboardingView.swift
//  ClothingTaggerAI
//
//  Created by Ignacio Cervino on 04/03/2025.
//

import OSLog
import SwiftUI

struct OnboardingView: View {
    private let logger = Logger.viewEvents
    @Environment(MLXModelLoader.self) var modelLoader
    @Environment(\.dismiss) private var dismiss
    @Binding var showOnboarding: Bool

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: .init(colors: [.black, .gray.opacity(0.9)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                Text("Preparing AI Model")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                Text("Downloading AI model for offline processing.")
                    .font(.title3)
                    .foregroundColor(.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Group {
                    switch modelLoader.loadState {
                    case .idle:
                        ProgressView()
                            .progressViewStyle(.circular)

                    case .loaded:
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    logger.debug("Onboarding completed")
                                    showOnboarding = false
                                }
                            }
                    }
                }
                .padding()
                .background(.ultraThickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Spacer()
            }
            .padding()
        }
        .task {
            do {
                _ = try await modelLoader.load()
            } catch {
                logger.error("Error loading model: \(error)")
            }
        }
    }
}
