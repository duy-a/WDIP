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
    var longtitude: Double = 0.0
    var parkStartTime: Date = Date.now.roundedDownToMinute
    var parkEndTime: Date?
    var address: String = ""
    var timerEndTime: Date?
    var reminderEndTime: Date?
    var createdAt: Date = Date.now
    var notes: String = ""

    var vehicle: Vehicle?

    init(coordinates: CLLocationCoordinate2D) {
        self.latitude = coordinates.latitude
        self.longtitude = coordinates.longitude
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
