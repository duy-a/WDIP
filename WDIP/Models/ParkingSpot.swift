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
    var id: String = UUID().uuidString
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

    var notificationId: String {
        guard let timerEndTime else { return "" }

        let latStr = String(format: "%.5f", latitude)
        let lonStr = String(format: "%.5f", longitude)
        let timestamp = Int(timerEndTime.timeIntervalSince1970)

        return "parking_\(latStr)_\(lonStr)_\(timestamp)"
    }
}

extension ParkingSpot {
    static func getAddressBy(coordinates: CLLocationCoordinate2D) async -> String {
        return await getMKAddressBy(latitude: coordinates.latitude, longitude: coordinates.longitude)?.fullAddress ?? ""
    }

    static func getAddressBy(latitude: Double, longitude: Double) async -> String {
        return await getMKAddressBy(latitude: latitude, longitude: longitude)?.fullAddress ?? ""
    }

    static func getMKAddressBy(latitude: Double, longitude: Double) async -> MKAddress? {
        let location: CLLocation = .init(latitude: latitude, longitude: longitude)

        do {
            guard let mapItem = try await MKReverseGeocodingRequest(location: location)?.mapItems.first else { return nil }

            return mapItem.address
        } catch {
            return nil
        }
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
