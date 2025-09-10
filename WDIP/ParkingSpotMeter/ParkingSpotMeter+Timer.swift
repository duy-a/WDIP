//
//  ParkingSpotMeter+Timer.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 10/9/25.
//

import SwiftUI

// MARK: Timer Section

extension ParkingSpotMeter {
    var calculatedTimerEnd: Date? {
        if isLongTermParking {
            return timerEndTime
        } else {
            let calendar: Calendar = .current

            let hours: Int = calendar.component(.hour, from: timerEndTime)
            let minutes: Int = calendar.component(.minute, from: timerEndTime)

            var dateComponents = DateComponents()
            dateComponents.hour = hours
            dateComponents.minute = minutes

            return calendar.date(byAdding: dateComponents, to: parkingSpot.parkingStartTime)
        }
    }

    @ViewBuilder
    var timerSection: some View {
        Section {
            LabeledContent {
                Text(parkingSpot.parkingStartTime, format: .dateTime)
            } label: {
                Label("Parked on", systemImage: "clock")
            }

            if parkingSpot.hasRunningTimer {
                timerRemainingTimeDisplay
            } else {
                timerPicker
            }
        } header: {
            Text("Meter Timer")
        } footer: {
            if let calculatedTimerEnd, calculatedTimerEnd < .now, !parkingSpot.hasRunningTimer {
                Text("Selected duration has already passed.")
                    .foregroundStyle(.red)
            }
        }
        .onAppear {
            parkingSpot.starTimer()
        }
    }
}

// MARK: Duration & End time picker

extension ParkingSpotMeter {
    @ViewBuilder
    var timerPicker: some View {
        Toggle("Long-term parking", systemImage: "parkingsign.circle", isOn: $isLongTermParking)
            .onChange(of: isLongTermParking) { _, newValue in
                if newValue {
                    timerEndTime = .now
                } else {
                    timerEndTime = Calendar.current.startOfDay(for: .now)
                }
            }

        DatePicker(selection: $timerEndTime,
                   displayedComponents: isLongTermParking ? [.date, .hourAndMinute] : [.hourAndMinute])
        {
            if isLongTermParking {
                Label("End Date", systemImage: "calendar")
            } else {
                Label("Duration", systemImage: "timer")
            }
        }
    }
}

// MARK: Countdown

extension ParkingSpotMeter {
    @ViewBuilder
    var timerRemainingTimeDisplay: some View {
        if let timerEndTime = parkingSpot.timerEndTime {
            LabeledContent {
                Text(timerEndTime, format: .dateTime)
            } label: {
                Label("End time", systemImage: "clock.badge")
            }
        }

        LabeledContent {
            Text(TimerManager.formatRemainingTime(parkingSpot.timerRemainingTime))
        } label: {
            Label("Remaining time", systemImage: "timer")
        }
    }
}

// MARK: Functinos

extension ParkingSpotMeter {
    func startTimer() {
        guard let calculatedTimerEnd, calculatedTimerEnd > .now else { return }

        parkingSpot.hasRunningTimer = true
        parkingSpot.timerEndTime = calculatedTimerEnd

        parkingSpot.starTimer()
    }

    func stopTimer() {
        parkingSpot.stopTimer()

        isLongTermParking = false
        timerEndTime = Calendar.current.startOfDay(for: .now)
    }
}
