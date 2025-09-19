//
//  ParkingSpot.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 13/9/25.
//

import Foundation
import MapKit
import SwiftData

@Model
final class ParkingSpot {
    var uuid: String = UUID().uuidString
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var parkingStartTime: Date = Date.now.roundedDownToMinute
    var parkingEndTime: Date?
    var address: String = ""
    var timerEndTime: Date?
    var reminderOption: Int?
    var reminderEndTime: Date?
    var createdAt: Date = Date.now
    var notes: String = ""

    var vehicle: Vehicle?

    init(coordinates: CLLocationCoordinate2D) {
        self.latitude = coordinates.latitude
        self.longitude = coordinates.longitude
    }

    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var coordinateRegion: MKCoordinateRegion {
        MKCoordinateRegion(center: coordinates,
                           span: .init(latitudeDelta: 0.001, longitudeDelta: 0.001))
    }

    var notificationId: String {
        guard let timerEndTime else { return "" }

        let latStr = String(format: "%.5f", latitude)
        let lonStr = String(format: "%.5f", longitude)
        let timestamp = Int(timerEndTime.timeIntervalSince1970)

        return "parking_\(latStr)_\(lonStr)_\(timestamp)"
    }
}

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
    func scheduleNotificationReminder() {
        guard let reminderOption, let reminderEndTime, let timerEndTime else { return }

        var notificationBody = ""
        let option: ReminderTimeOption = .init(rawValue: reminderOption)!

        switch option {
        case .before5min, .before10min, .before15min:
            notificationBody = "Your parking meter will expire in \(option.rawValue) minutes."
        case .atTheEnd:
            notificationBody = "Your parking meter has expired."
        case .custom:
            if reminderEndTime == timerEndTime {
                notificationBody = "Your parking meter has expired."
            } else {
                notificationBody = "Your parking meter will expire on \(timerEndTime.formatted(date: .abbreviated, time: .shortened))"
            }
        }

        Task {
            await NotificationManager.shared.scheduleNotification(id: notificationId,
                                                                  title: vehicle?.name ?? "Your vehicle",
                                                                  body: notificationBody,
                                                                  date: reminderEndTime)
        }
    }

    func cancelNotificationReminder() {
        NotificationManager.shared.cancelNotification(id: notificationId)
    }
}
