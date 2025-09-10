//
//  ParkingSpotMeterReminder.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 8/9/25.
//

import SwiftUI

enum ReminderTimeOption: Int, CaseIterable, Identifiable {
    case before5min = 5
    case before10min = 10
    case before15min = 15
    case atTheEnd = 0
    case custom = -999

    var id: Self { self }

    var label: String {
        switch self {
        case .before5min: return "5 minutes before"
        case .before10min: return "10 minutes before"
        case .before15min: return "15 minutes before"
        case .atTheEnd: return "At the end"
        case .custom: return "Custom"
        }
    }
}

extension ParkingSpotMeter {
    var latestReminderDate: Date {
        if parkingSpot.timerEndTime == Calendar.current.startOfDay(for: .distantPast) {
            if timerEndTime > .now {
                return timerEndTime
            } else {
                return .now
            }
        } else {
            return parkingSpot.timerEndTime
        }
    }

    var validReminderTime: Bool {
        guard toggleReminder, reminderTimeOption != .custom else { return true }

        let reminderTime = Calendar.current.date(byAdding: .minute,
                                                 value: -reminderTimeOption.rawValue,
                                                 to: latestReminderDate)!

        return reminderTime > .now
    }

    var notificationBodyContent: String {
        switch reminderTimeOption {
        case .before5min, .before10min, .before15min:
            return "Your parking meter will expire in \(reminderTimeOption.rawValue) minutes."
        case .atTheEnd:
            return "Your parking meter has expired."
        case .custom:
            return "Your parking meter will expire in \(formattedRemainingTime)."
        }
    }

    @ViewBuilder
    var meterReminder: some View {
        Section {
            Toggle("Remind me", systemImage: "bell", isOn: $toggleReminder)

            if toggleReminder {
                Picker(selection: $reminderTimeOption) {
                    ForEach(ReminderTimeOption.allCases) { option in
                        Text(option.label).tag(option)
                    }
                } label: {
                    Label("Time", systemImage: "clock.badge.exclamationmark")
                }
                .disabled(parkingSpot.hasReminder)

                if reminderTimeOption == .custom {
                    DatePicker(selection: $parkingSpot.reminderTime, in: .now ... latestReminderDate) {
                        Label("", systemImage: "calendar")
                    }
                    .disabled(parkingSpot.hasReminder)
                }
            }

            if parkingSpot.hasRunningTimer && !parkingSpot.hasReminder && toggleReminder {
                Button("Set reminder", systemImage: "alarm", action: scheduleReminder)
            }
        } header: {
            Text("Reminder")
        } footer: {
            if !validReminderTime && !parkingSpot.hasReminder {
                Text("Reminder cannot be set in the past")
                    .foregroundStyle(.red)
            }
        }
        .onAppear {
            handleOnAppear()
        }
        .onChange(of: toggleReminder) { _, newValue in
            newValue ? requestNotificationPermission() : clearReminder()
        }
        .alert("Notifications Disabled", isPresented: $showingPermissionDeniedAlert) {
            Button("Open Settings", action: openAppSettings)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable notifications in Settings to recieve reminders")
        }
    }
}

extension ParkingSpotMeter {
    func scheduleReminder() {
        guard toggleReminder,
              validReminderTime,
              parkingSpot.hasRunningTimer,
              parkingSpot.reminderTime > parkingSpot.parkingStartTime,
              parkingSpot.reminderTime <= timerEndTime || parkingSpot.reminderTime <= parkingSpot.timerEndTime
        else {
            clearReminder()
            return
        }

        Task {
            parkingSpot.hasReminder = true
            parkingSpot.reminderOption = reminderTimeOption.rawValue

            if reminderTimeOption != .custom {
                parkingSpot.reminderTime = Calendar.current.date(byAdding: .minute,
                                                                 value: -reminderTimeOption.rawValue,
                                                                 to: latestReminderDate)!
            }

            await notificationManager.scheduleNotification(id: generateNotificationID(),
                                                           title: parkingSpot.vehicle?.name ?? "Your vehicle",
                                                           body: notificationBodyContent,
                                                           date: parkingSpot.reminderTime)
        }
    }

    func clearReminder() {
        toggleReminder = false
        reminderTimeOption = .before5min

        parkingSpot.hasReminder = false
        parkingSpot.reminderTime = .now
        parkingSpot.reminderOption = ReminderTimeOption.before5min.rawValue

        notificationManager.cancelNotification(id: generateNotificationID())
    }

    func clearReminderIfDelivered() {
        guard parkingSpot.hasReminder else { return }
        Task {
            if await notificationManager.isDelivered(id: generateNotificationID()) {
                clearReminder()
            }
        }
    }

    private func handleOnAppear() {
        toggleReminder = parkingSpot.hasReminder
        reminderTimeOption = ReminderTimeOption(rawValue: parkingSpot.reminderOption) ?? .before5min
    }

    private func generateNotificationID() -> String {
        let latStr = String(format: "%.5f", parkingSpot.latitude)
        let lonStr = String(format: "%.5f", parkingSpot.longitude)
        let timestamp = Int(parkingSpot.timerEndTime.timeIntervalSince1970)

        return "parking_\(latStr)_\(lonStr)_\(timestamp)"
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
