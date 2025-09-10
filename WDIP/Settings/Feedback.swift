//
//  Feedback.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 3/9/25.
//

import SwiftUI

struct Feedback: View {
    var body: some View {
        List {
            Section {
                Text("WDIP: Where Did I Park? is run with no employees (just 1 person), no VC funding and a sustainable work-life balance. Feedback is always welcomed.")
            }

            Section("App") {
//                ButtonExternalLink(title: "Twitter / X", link: Constants.APP_TWITTER_LINK)
//                ButtonExternalLink(title: "Mastadon", link: Constants.TERMS_LINK)
                ButtonExternalLink(title: "Send Email", link: "mailto:\(Constants.SUPPORT_EMAIL)")
            }

            Section("Me") {
                ButtonExternalLink(title: "Twitter / X", link: Constants.DEV_TWITTER_LINK)
                ButtonExternalLink(title: "Mastadon", link: Constants.DEV_MASTADON_LINK)
            }
            
            Section {
                Text("I try to read every message, but not all will be receive the response.")
            }
        }
        .navigationTitle("Send Feedback")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    Feedback()
}
