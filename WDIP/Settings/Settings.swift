//
//  Settings.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 17/9/25.
//

import SwiftUI

struct Settings: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: Feedback()) {
                        Label("Send feedback", systemImage: "waveform.path.ecg.text.clipboard")
                    }
                    ButtonExternalLink(title: "Join TestFlight Beta", systemImage: "paperplane", link: Constants.TESTFLIGHT_LINK)
                }

                Section {
                    NavigationLink(destination: About()) {
                        Label("About", systemImage: "info")
                    }
                }
            }
            .sheetToolbar("Settings")
        }
    }
}
