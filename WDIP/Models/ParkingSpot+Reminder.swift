//
//  ParkingSpot+Reminder.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 10/9/25.
//

import Foundation

extension ParkingSpot {
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
}

extension ParkingSpot {
    func generateReminderId() -> String {
        guard let timerEndTime else { return "" }

        let latStr = String(format: "%.5f", latitude)
        let lonStr = String(format: "%.5f", longitude)
        let timestamp = Int(timerEndTime.timeIntervalSince1970)

        return "parking_\(latStr)_\(lonStr)_\(timestamp)"
    }

    func scheduleReminder() {
        guard let reminderTime, let reminderOption = ReminderTimeOption(rawValue: reminderOption) else { return }

        var notificationBody = ""

        switch reminderOption {
        case .before5min, .before10min, .before15min:
            notificationBody = "Your parking meter will expire in \(reminderOption.rawValue) minutes."
        case .atTheEnd:
            notificationBody = "Your parking meter has expired."
        case .custom:
            notificationBody = "Your parking meter will expire in \(TimerManager.formatRemainingTime(timerRemainingTime))."
        }

        Task {
            await NotificationManager.shared.scheduleNotification(id: generateReminderId(),
                                                                  title: vehicle?.name ?? "Your vehicle",
                                                                  body: notificationBody,
                                                                  date: reminderTime)
        }
    }

    func cancelReminder() {
        clearReminder()
        NotificationManager.shared.cancelNotification(id: generateReminderId())
    }

    func clearReminderIfDelivered() {
        guard hasReminder else { return }
        Task {
            if await NotificationManager.shared.isDelivered(id: generateReminderId()) {
                clearReminder()
            }
        }
    }

    private func clearReminder() {
        hasReminder = false
        reminderOption = ReminderTimeOption.custom.rawValue
        reminderTime = nil
    }
}
