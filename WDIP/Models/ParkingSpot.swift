//
//  ParkingSpot.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 23/7/25.
//

import CoreLocation
import Foundation
import MapKit
import SwiftData

@Model
final class ParkingSpot {
    var latitude: Double
    var longitude: Double
    var address: String = ""
    var parkingStartTime: Date = Date.now
    var parkingEndTime: Date = Date.now
    var notes: String = ""
    var photo: Data?

    var vehicle: Vehicle?

    init(latitude: Double = 0, longitude: Double = 0) {
        self.latitude = latitude
        self.longitude = longitude

        Task {
            await getAddress()
        }
    }

    var isCurrentParkingSpot: Bool {
        guard let vehicle else { return false }

        if self == vehicle.currentParkingSpot {
            return true
        }

        return false
    }

    private func getAddress() async {
        let location = CLLocation(latitude: latitude, longitude: longitude)

        do {
            guard let request = MKReverseGeocodingRequest(location: location) else { return }

            let mapItems = try await request.mapItems

            guard let mapItem = mapItems.first,
                  let fullAddress = mapItem.addressRepresentations?.fullAddress(includingRegion: true, singleLine: true)
            else { return }

            address = fullAddress

        } catch {
            // TODO: catch error
        }
    }
    
    func getMKAdress() async -> MKAddress? {
        let location = CLLocation(latitude: latitude, longitude: longitude)

        do {
            guard let request = MKReverseGeocodingRequest(location: location) else { return nil }

            let mapItems = try await request.mapItems

            guard let mapItem = mapItems.first else { return nil }
            
            return mapItem.address
        } catch {
            // TODO: catch error
            return nil
        }
    }

    var parkingDuration: String {
        let calendar = Calendar.current
        let startTime: Date = parkingStartTime
        var endTime: Date = parkingEndTime

        if isCurrentParkingSpot {
            endTime = .now
        }

        var totalMinutes = calendar.dateComponents([.minute], from: endTime, to: startTime).minute ?? 0
        totalMinutes += 1

        if totalMinutes < 60 {
            return "\(totalMinutes) minute" + (totalMinutes == 1 ? "" : "s")
        }

        let totalHours = totalMinutes / 60
        if totalHours < 24 {
            return "\(totalHours) hour" + (totalHours == 1 ? "" : "s")
        }

        let totalDays = totalHours / 24 // Or totalMinutes / (60 * 24)
        return "\(totalDays) day" + (totalDays == 1 ? "" : "s")
    }
}
