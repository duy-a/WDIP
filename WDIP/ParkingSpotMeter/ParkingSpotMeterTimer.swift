//
//  ParkingSpotMeterTimer.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 5/9/25.
//

import SwiftUI

extension ParkingSpotMeter {
    var formattedRemainingTime: String {
        TimerManager.formatRemainingTime(remainingTime)
    }

    var timerEndTime: Date {
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
                    DatePicker(selection: $longTermParkingEndDate, in: .now...) {
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
                if showingWarning {
                    Text("Selected duration has already passed.")
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

extension ParkingSpotMeter {
    func startMeter() {
        guard timerEndTime > .now else {
            showingWarning = true
            return
        }

        showingWarning = false

        parkingSpot.hasRunningTimer = true
        parkingSpot.timerEndTime = timerEndTime

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

        showingWarning = false
    }

    func startTimer() {
        stopTimer()

        timerTask = TimerManager.starTimer(
            endTime: parkingSpot.timerEndTime,
            onTick: { remaining in
                remainingTime = remaining
                clearReminderIfDelivered()
            },
            onComplete: {
                resetMeter()
                clearReminder()
            }
        )
    }

    func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
}
