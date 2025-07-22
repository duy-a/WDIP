//
//  OnboardingView.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 21/7/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage: Int = 1
    private let totalPages = 5

    var body: some View {
        NavigationStack {
            TabView(selection: $currentPage) {
                OnboardingPageView(
                    emoji: "👋",
                    title: "Where Did I Park?",
                    subtitle: "Never lose your car again. Track your parking spots with just one tap."
                )
                .tag(1)

                OnboardingPageView(
                    emoji: "📍",
                    title: "One-Tap Parking Save",
                    subtitle: "No typing required. Get guided straight back to your car."
                )
                .tag(2)

                OnboardingPageView(
                    emoji: "📝",
                    title: "Finer details",
                    subtitle: "Add notes, track history, set timers, and so much more"
                )
                .tag(3)

                OnboardingPageView(
                    emoji: "🔐",
                    title: "Your Data Stays Yours",
                    subtitle: "Parking spots and notes are encrypted, accessible only by you."
                )
                .tag(4)

                OnboardingPageView(
                    emoji: "🛰️",
                    title: "Location Permission",
                    subtitle: "To get started, we need your location access to save and guide you back to your car.",
                    actionName: "Get Started"
                ) {
                    //
                }
                .tag(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            .toolbar {
                if currentPage > 1 {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            currentPage -= 1
                        } label: {
                            Label("Back", systemImage: "chevron.left")
                        }
                    }
                }

                if currentPage < totalPages {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            currentPage += 1
                        } label: {
                            Label("Next", systemImage: "chevron.right")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
}
