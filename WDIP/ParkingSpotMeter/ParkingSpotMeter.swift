//
//  ParkingSpotMeter.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 8/9/25.
//

import SwiftUI

struct ParkingSpotMeter: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NotificationManager.self) var notificationManager

    @Bindable var parkingSpot: ParkingSpot

    @State var timerTask: Task<Void, Never>? = nil

    @State var duration: Date = Calendar.current.startOfDay(for: .distantPast)
    @State var remainingTime: TimeInterval = 0
    @State var isLongTermParking: Bool = false
    @State var longTermParkingEndDate: Date = .now
    @State var showingWarning: Bool = false

    @State var toggleReminder: Bool = false
    @State var reminderTimeOption: ReminderTimeOption = .before5min
    @State var showingPermissionDeniedAlert: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                meterTimer
                meterReminder
            }
            .sheetToolbar("Timer & Reminder") {
                toolbarContent
            }
            .onAppear {
                onAppear()
            }
            .onDisappear {
                stopTimer()
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// #Preview {
//    ParkingSpotMeter()
// }

extension ParkingSpotMeter {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        if parkingSpot.hasRunningTimer {
            ToolbarItem(placement: .primaryAction) {
                Button("Stop Meter", systemImage: "stop.fill", role: .cancel, action: stopAction)
            }
        } else {
            ToolbarItem(placement: .primaryAction) {
                Button("Start Meter", systemImage: "stopwatch", role: .confirm, action: startAction)
            }
        }
    }
}

extension ParkingSpotMeter {
    func onAppear() {
        if parkingSpot.hasRunningTimer, parkingSpot.timerEndTime > .now {
            startTimer()
        } else {
            stopAction()
        }
    }

    func startAction() {
        startMeter()
        scheduleReminder()
    }

    func stopAction() {
        resetMeter()
        clearReminder()
    }
}
