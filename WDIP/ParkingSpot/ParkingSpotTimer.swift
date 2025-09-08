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

                    if remainingTime > 0 {
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
                            .onChange(of: longTermParkingEndDate) { _, _ in
                                clearWarning()
                            }
                        } else {
                            DatePicker(selection: $duration, displayedComponents: [.hourAndMinute]) {
                                Label("Duration", systemImage: "timer")
                            }
                            .onChange(of: duration) { _, _ in
                                clearWarning()
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
                calculateRemainingTime()
                startTimer()
                clearWarning()
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
                Button("Clear", systemImage: "stop.fill", role: .cancel, action: clearTimer)
            }
        } else {
            ToolbarItem(placement: .primaryAction) {
                Button("Start Timer", systemImage: "stopwatch", role: .confirm, action: startCountdown)
            }
        }
    }
}

extension ParkingSpotTimer {
    private func startTimer() {
        stopTimer()

        guard parkingSpot.hasRunningTimer, remainingTime > 0 else { return }

        timerTask = Task { @MainActor in
            while !Task.isCancelled && parkingSpot.hasRunningTimer && remainingTime > 0 {
                try? await Task.sleep(nanoseconds: 1000000000)
                remainingTime -= 1
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    private func startCountdown() {
        let calendar = Calendar.current

        var timerEndTime: Date?

        if isLongTermParking {
            timerEndTime = longTermParkingEndDate
        } else {
            let hours: Int = calendar.component(.hour, from: duration)
            let minutes: Int = calendar.component(.minute, from: duration)

            guard hours > 0 || minutes > 0 else { return }

            var dateComponents = DateComponents()
            dateComponents.hour = hours
            dateComponents.minute = minutes

            timerEndTime = calendar.date(byAdding: dateComponents, to: parkingSpot.parkingStartTime)
        }

        guard let timerEndTime else { return }

        parkingSpot.timerEndTime = timerEndTime

        calculateRemainingTime()
        startTimer()
    }

    private func calculateRemainingTime() {
        let timeDiff = getTimeDiff(from: .now, to: parkingSpot.timerEndTime)
        remainingTime = TimeInterval(timeDiff.days * 86400 + timeDiff.hours * 3600 + timeDiff.minutes * 60 + timeDiff.seconds)

        if remainingTime > 0 {
            parkingSpot.hasRunningTimer = true
        } else {
            parkingSpot.hasRunningTimer = false
            isShowingWarning = true
        }
    }

    private func getTimeDiff(from: Date, to: Date) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let timeDiffComponent = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: from, to: to)
        let days = timeDiffComponent.day ?? 0
        let hours = timeDiffComponent.hour ?? 0
        let minutes = timeDiffComponent.minute ?? 0
        let seconds = timeDiffComponent.second ?? 0

        return (days, hours, minutes, seconds)
    }

    private func clearTimer() {
        stopTimer()

        parkingSpot.hasRunningTimer = false
        parkingSpot.timerEndTime = Calendar.current.startOfDay(for: .distantPast)

        duration = Calendar.current.startOfDay(for: .distantPast)
        isLongTermParking = false
        longTermParkingEndDate = .now
        remainingTime = 0

        clearWarning()
    }

    private func clearWarning() {
        isShowingWarning = false
    }
}
