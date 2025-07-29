//
//  OnboardingPageView.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 21/7/25.
//

import SwiftUI

struct OnboardingPageView: View {
    var emoji: String
    var title: String
    var subtitle: String
    var actionName: String = ""
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 40) {
            Text(emoji)
                .lineLimit(1)
                .font(.system(size: 85))
                .padding(30)
                .glassEffect(in: .circle)
            
            VStack(spacing: 15) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                
                Button(actionName) {
                    (action ?? {})()
                }
                .tint(.indigo)
                .buttonStyle(.glassProminent)
                .controlSize(.extraLarge)
                .padding(.vertical, 25)
                .opacity(action != nil ? 1 : 0)
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    OnboardingPageView(emoji: "🔐", title: "Where Did I Park?", subtitle: "Never lose your vehicle again. Track your parking spots with just one tap.", actionName: "Get Started") {
        // Some action
    }
}
