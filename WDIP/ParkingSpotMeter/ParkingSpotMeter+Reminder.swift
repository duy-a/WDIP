//
//  ParkingSpotMeter+Reminder.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 10/9/25.
//

import SwiftUI

// MARK: Timer Section

extension ParkingSpotMeter {
    var calculatedReminderTime: Date {
        switch reminderOption {
        case .before5min, .before10min, .before15min, .atTheEnd:
            return Calendar.current.date(byAdding: .minute,
                                         value: -reminderOption.rawValue,
                                         to: latestReminderDate)!
        case .custom:
            return reminderTime
        }
    }

    var latestReminderDate: Date {
        guard let timerEndTime = parkingSpot.timerEndTime else { return .now }

        if timerEndTime > .now {
            return timerEndTime
        } else {
            return .now
        }
    }

    @ViewBuilder
    var reminderSection: some View {
        Section {
            Toggle("Remind me", systemImage: "bell", isOn: $enabledReminder)
                .onChange(of: enabledReminder) { _, newValue in
                    newValue ? requestNotificationPermission() : cancelReminder()
                }

            if enabledReminder {
                Picker(selection: $reminderOption) {
                    ForEach(ParkingSpot.ReminderTimeOption.allCases) { option in
                        Text(option.label).tag(option)
                    }
                } label: {
                    Label("Time", systemImage: "clock.badge.exclamationmark")
                }
                .disabled(parkingSpot.hasReminder)

                if reminderOption == .custom {
                    DatePicker(selection: $reminderTime, in: .now ... latestReminderDate) {
                        Label("", systemImage: "calendar")
                    }
                    .disabled(parkingSpot.hasReminder)
                }

                if parkingSpot.hasRunningTimer && !parkingSpot.hasReminder {
                    Button("Set reminder", systemImage: "alarm", action: scheduleReminder)
                }
            }
        } header: {
            Text("Reminder")
        } footer: {
            if enabledReminder, calculatedReminderTime < .now {
                Text("Reminder cannot be set in the past")
                    .foregroundStyle(.red)
            }
        }
        .alert("Notifications Disabled", isPresented: $showingPermissionDeniedAlert) {
            Button("Open Settings", action: openAppSettings)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable notifications in Settings to recieve reminders")
        }
        .onChange(of: parkingSpot.hasReminder) { _, newValue in
            if !newValue {
                enabledReminder = false
                reminderOption = .before5min
                reminderTime = .now
            }
        }
    }
}

extension ParkingSpotMeter {
    func scheduleReminder() {
        guard enabledReminder,
              parkingSpot.hasRunningTimer,
              let timerEndTime = parkingSpot.timerEndTime,
              calculatedReminderTime > .now,
              calculatedReminderTime <= timerEndTime else { return }

        parkingSpot.hasReminder = true
        parkingSpot.reminderTime = calculatedReminderTime

        parkingSpot.scheduleReminder()
    }

    func cancelReminder() {
        enabledReminder = false
        reminderOption = .before5min
        reminderTime = .now

        parkingSpot.cancelReminder()
    }

    private func requestNotificationPermission() {
        Task { @MainActor in
            await notificationManager.requestPermission()

            if !notificationManager.isAuthorized {
                showingPermissionDeniedAlert = true
                parkingSpot.hasReminder = false
            }
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }

        UIApplication.shared.open(url)
    }
}
