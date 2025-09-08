//
//  ParkingSpotTimer.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 5/9/25.
//

import SwiftUI

struct ParkingSpotTimer: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var parkingSpot: ParkingSpot

    @State private var timerTask: Task<Void, Never>? = nil

    @State private var duration: Date = Calendar.current.startOfDay(for: .distantPast)
    @State private var remainingTime: TimeInterval = 0
    @State private var isLongTermParking: Bool = false
    @State private var longTermParkingEndDate: Date = .now
    @State private var isShowingWarning: Bool = false

    @State private var toggleReminder: Bool = false

    var formattedRemainingTime: String {
        let totalSeconds = max(Int(remainingTime), 0)
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if days > 0 {
            return String(format: "%dd %02d:%02d:%02d", days, hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent {
                        Text(parkingSpot.parkingStartTime, format: .dateTime)
                    } label: {
                        Label("Parked time", systemImage: "clock")
                    }

                    if parkingSpot.hasRunningTimer {
                        LabeledContent {
                            Text(parkingSpot.timerEndTime, format: .dateTime)
                        } label: {
                            Label("End time", systemImage: "clock.badge")
                        }

                        LabeledContent {
                            Text(formattedRemainingTime)
                        } label: {
                            Label("Remaining time", systemImage: "timer")
                        }
                    } else {
                        Toggle("Long-term parking", systemImage: "parkingsign.circle", isOn: $isLongTermParking)

                        if isLongTermParking {
                            DatePicker(selection: $longTermParkingEndDate, in: parkingSpot.parkingStartTime...) {
                                Label("End Date", systemImage: "calendar")
                            }
                        } else {
                            DatePicker(selection: $duration, displayedComponents: [.hourAndMinute]) {
                                Label("Duration", systemImage: "timer")
                            }
                        }
                    }
                } header: {
                    Text("Timer")
                } footer: {
                    VStack(alignment: .leading) {
                        Text("The timer always starts from your parking time.")
                        if isShowingWarning {
                            Text("Selected duration has already passed.")
                                .foregroundStyle(.red)
                        }
                    }
                }

                Section {
                    Toggle("Remind me", systemImage: "bell", isOn: $toggleReminder)
                    Label("Time", systemImage: "alarm")
                }
            }
            .navigationTitle("Timer & Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
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
//    ParkingSpotTimer()
// }

extension ParkingSpotTimer {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", systemImage: "xmark", role: .close, action: { dismiss() })
        }

        if parkingSpot.hasRunningTimer {
            ToolbarItem(placement: .primaryAction) {
                Button("Stop Meter", systemImage: "stop.fill", role: .cancel, action: resetMeter)
            }
        } else {
            ToolbarItem(placement: .primaryAction) {
                Button("Start Meter", systemImage: "stopwatch", role: .confirm, action: startMeter)
            }
        }
    }
}

extension ParkingSpotTimer {
    private func onAppear() {
        if parkingSpot.hasRunningTimer && parkingSpot.timerEndTime > .now {
            startTimer()
        } else {
            resetMeter()
        }
    }
    
    private func startMeter() {
        guard getTimerEndTime() > .now else {
            isShowingWarning = true
            return
        }

        isShowingWarning = false

        parkingSpot.hasRunningTimer = true
        parkingSpot.timerEndTime = getTimerEndTime()

        startTimer()
    }

    private func resetMeter() {
        stopTimer()

        parkingSpot.hasRunningTimer = false
        parkingSpot.timerEndTime = Calendar.current.startOfDay(for: .distantPast)

        duration = Calendar.current.startOfDay(for: .distantPast)
        isLongTermParking = false
        longTermParkingEndDate = .now
        remainingTime = 0

        isShowingWarning = false
    }

    private func getTimerEndTime() -> Date {
        if isLongTermParking {
            return longTermParkingEndDate
        } else {
            let hours: Int = Calendar.current.component(.hour, from: duration)
            let minutes: Int = Calendar.current.component(.minute, from: duration)

            var dateComponents = DateComponents()
            dateComponents.hour = hours
            dateComponents.minute = minutes

            return Calendar.current.date(byAdding: dateComponents, to: parkingSpot.parkingStartTime) ?? parkingSpot.parkingStartTime
        }
    }

    private func startTimer() {
        stopTimer()

        timerTask = Task { @MainActor in
            var nextTick = ContinuousClock.now

            while !Task.isCancelled && parkingSpot.hasRunningTimer {
                remainingTime = parkingSpot.timerEndTime.timeIntervalSinceNow

                guard remainingTime > 0 else {
                    resetMeter()
                    break
                }

                nextTick = nextTick.advanced(by: .seconds(1))
                try? await Task.sleep(until: nextTick, clock: .continuous)
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
}
