//
//  ParkingSpotMeterTimer.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 5/9/25.
//

import SwiftUI

extension ParkingSpotMeter {
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

    @ViewBuilder
    var meterTimer: some View {
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
    }
}

extension ParkingSpotMeter {
    func startMeter() {
        guard getTimerEndTime() > .now else {
            isShowingWarning = true
            return
        }

        isShowingWarning = false

        parkingSpot.hasRunningTimer = true
        parkingSpot.timerEndTime = getTimerEndTime()

        startTimer()
    }

    func resetMeter() {
        stopTimer()

        parkingSpot.hasRunningTimer = false
        parkingSpot.timerEndTime = Calendar.current.startOfDay(for: .distantPast)

        duration = Calendar.current.startOfDay(for: .distantPast)
        isLongTermParking = false
        longTermParkingEndDate = .now
        remainingTime = 0

        isShowingWarning = false
    }

    func getTimerEndTime() -> Date {
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

    func startTimer() {
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

    func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
}
