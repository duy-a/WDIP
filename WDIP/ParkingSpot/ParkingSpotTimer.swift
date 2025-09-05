//
//  ParkingSpotTimer.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 5/9/25.
//

import SwiftUI

struct ParkingSpotTimer: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                //
            }
            .toolbar { toolbarContent }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    ParkingSpotTimer()
}

extension ParkingSpotTimer {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", systemImage: "xmark", role: .cancel, action: { dismiss() })
        }
    }
}
