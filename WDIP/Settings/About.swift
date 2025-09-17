//
//  About.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 17/9/25.
//

import SwiftUI

struct About: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        List {
            Section {
                Text("WDIP: Where Did I Park?")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                VStack {
                    Text("App Version: \(Bundle.main.appVersion)")
                    Text("By Duy Anh Ngac")
                    Text("© 2025")
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(.secondary)
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            Section {
                ButtonExternalLink(title: "Privacy Policy", link: Constants.PRIVACY_LINK)
                ButtonExternalLink(title: "Terms of Use", link: Constants.TERMS_LINK)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}
