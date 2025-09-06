//
//  ParkingSpotTimer.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 5/9/25.
//

import Combine
import SwiftUI

struct ParkingSpotTimer: View {
    @Environment(\.dismiss) private var dismiss

    @Bindable var parkingSpot: ParkingSpot

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var duration: Date = Calendar.current.startOfDay(for: .distantPast)
    @State private var remainingTime: TimeInterval = 0
    @State private var isLongTermParking: Bool = false
    @State private var longTermParkingEndDate: Date = .now

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
                Text(parkingSpot.timerEndTime, format: .dateTime)
                Text(longTermParkingEndDate, format: .dateTime)

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
                            DatePicker(selection: $longTermParkingEndDate) {
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
                    Text("The timer always starts from your parking time.")
                }

                Section {
                    Toggle("Remind me", systemImage: "bell", isOn: $toggleReminder)
                    Label("Time", systemImage: "alarm")
                }
            }
            .navigationTitle("Timer & Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .onAppear { onAppear() }
            .onReceive(timer) { _ in
                countdown()
            }
        }
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

        ToolbarItem(placement: .primaryAction) {
            Button("Clear", systemImage: "arrow.clockwise", role: .cancel, action: clearTimer)
        }

        ToolbarSpacer(.fixed, placement: .primaryAction)

        ToolbarItem(placement: .primaryAction) {
            Button("Start Timer", systemImage: "stopwatch", role: .confirm, action: startTimer)
        }
    }
}

extension ParkingSpotTimer {
    private func onAppear() {
        calculateRemainingTime()
    }

    private func countdown() {
        guard parkingSpot.hasRunningTimer, remainingTime > 0 else { return }
        remainingTime -= 1
    }

    private func startTimer() {
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

        parkingSpot.hasRunningTimer = true
        parkingSpot.timerEndTime = timerEndTime

        calculateRemainingTime()
    }

    private func calculateRemainingTime() {
        if parkingSpot.hasRunningTimer {
            let timeDiff = getTimeDiff(from: .now, to: parkingSpot.timerEndTime)
            remainingTime = TimeInterval(timeDiff.days * 86400 + timeDiff.hours * 3600 + timeDiff.minutes * 60 + timeDiff.seconds)
        }
    }

    private func getTimeDiff(from: Date, to: Date) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let timeDiffComponent = Calendar.current.dateComponents([.hour, .minute, .second], from: from, to: to)
        let days = timeDiffComponent.day ?? 0
        let hours = timeDiffComponent.hour ?? 0
        let minutes = timeDiffComponent.minute ?? 0
        let seconds = timeDiffComponent.second ?? 0

        return (days, hours, minutes, seconds)
    }

    private func clearTimer() {
        parkingSpot.hasRunningTimer = false
        parkingSpot.timerEndTime = Calendar.current.startOfDay(for: .distantPast)

        duration = Calendar.current.startOfDay(for: .distantPast)
        remainingTime = 0
    }
}
