//
//  SwiftUIView.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 10/9/25.
//

import SwiftUI

struct ParkingSpotMeter: View {
    @Bindable var parkingSpot: ParkingSpot

    @State var timerEndTime: Date = Calendar.current.startOfDay(for: .now)
    @State var isLongTermParking: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                timerSection
            }
            .sheetToolbar("Meter & Reminder") {
                toolbarContent
            }
        }
    }
}

// #Preview {
//    SwiftUIView(parkingSpot: StoreProvider.sampleParkingSpot1)
// }

extension ParkingSpotMeter {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            if parkingSpot.hasRunningTimer {
                Button("Stop Meter", systemImage: "stop.fill", role: .cancel, action: stopMeter)
            } else {
                Button("Start Meter", systemImage: "stopwatch", role: .confirm, action: startMeter)
            }
        }
    }
}

extension ParkingSpotMeter {
    private func startMeter() {
        startTimer()
    }

    private func stopMeter() {
        stopTimer()
    }
}
