//
//  Settings.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 29/8/25.
//

import SwiftUI

struct Settings: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    //
                }
                
                Section {
                    NavigationLink(destination: About()) {
                        Label("Send Feedback", systemImage: "waveform.path.ecg.text.clipboard")
                    }
                    NavigationLink(destination: About()) {
                        Label("Rate & Review WDIP", systemImage: "star")
                    }
                    NavigationLink(destination: About()) {
                        Label("Join TestFlight Beta", systemImage: "paperplane")
                    }
                }

                Section {
                    NavigationLink(destination: About()) {
                        Label("About", systemImage: "info")
                    }
                }
            }
            .toolbar {
                toolbarContent()
            }
        }
    }
}

#Preview {
    Settings()
}

extension Settings {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Close", systemImage: "xmark", action: { dismiss() })
        }
    }
}
