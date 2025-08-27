//
//  Onboarding.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 21/7/25.
//

import SwiftUI

struct OnboardingStep {
    let image: String
    let title: String
    let description: String
}

struct Onboarding: View {
    @State private var currentStep: Int = 0

    let steps: [OnboardingStep] = [
        OnboardingStep(image: "parkingsign.square.fill", title: "Where Did I Park?", description: "Never lose your vehicle again. Track your parking spots with just one tap."),
        OnboardingStep(image: "mappin.and.ellipse", title: "One-Tap Parking Save", description: "No typing required. Get guided straight back to your vehicle."),
        OnboardingStep(image: "list.bullet.rectangle.fill", title: "Finer details", description: "Add notes, track history, set timers, and so much more"),
        OnboardingStep(image: "lock.shield.fill", title: "Your Data Stays Yours", description: "Parking spots and notes are encrypted, accessible only by you."),
        OnboardingStep(image: "location.fill", title: "Location Permission", description: "We need your location access to save and guide you back to your vehicle."),
    ]

    var body: some View {
        VStack {
            TabView(selection: $currentStep) {
                ForEach(0 ..< steps.count, id: \.self) { index in
                    VStack(spacing: 20) {
                        Spacer()

                        Image(systemName: steps[index].image)
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .frame(width: 150, height: 150)
                            .padding()
                            //                            .glassEffect(in: .circle)
                            .foregroundStyle(.indigo.gradient)

                        Text(steps[index].title)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(steps[index].description)
                            .font(.title3)
                            .foregroundStyle(.secondary)

                        Spacer()
                    }
                    .tag(index)
                }
            }
            .padding(.horizontal)
            .multilineTextAlignment(.center)
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            HStack(spacing: 10) {
                Button {
                    withAnimation { currentStep -= 1 }

                } label: {
                    Label("Back", systemImage: "chevron.backward")
                        .labelStyle(.titleOnly)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
                .disabled(currentStep <= 0)

                Button {
                    if currentStep < steps.count - 1 {
                        withAnimation { currentStep += 1 }
                    } else {
                        UserDefaults.standard.set(true, forKey: "isViewedOnboarding")
                    }
                } label: {
                    Label("Next", systemImage: "chevron.forward")
                        .labelStyle(.titleOnly)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
            }
            .controlSize(.extraLarge)
            .padding()
        }
    }
}

#Preview {
    Onboarding()
}
