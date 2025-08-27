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
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var address: String = ""
    var parkingStartTime: Date = Date.now
    var parkingEndTime: Date = Date.now
    var notes: String = ""

    var vehicle: Vehicle?

    init(latitude: Double = 0, longitude: Double = 0) {
        self.latitude = latitude
        self.longitude = longitude

        getAddress()
    }

    convenience init(coordinates: CLLocationCoordinate2D) {
        self.init()
        self.latitude = coordinates.latitude
        self.longitude = coordinates.longitude
    }

    var isCurrentParkingSpot: Bool {
        guard let vehicle else { return false }

        if self == vehicle.activeParkingSpot {
            return true
        }

        return false
    }

    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func getDirectionsInMaps() {
        Task {
            guard let mkAddress = await getMKAdress() else { return }
            let location = CLLocation(latitude: latitude, longitude: longitude)

            let destinationMapItem = MKMapItem(location: location, address: mkAddress)
            destinationMapItem.name = vehicle?.name

            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]

            destinationMapItem.openInMaps(launchOptions: launchOptions)
        }
    }

    var parkingDuration: String {
        let calendar = Calendar.current
        let startTime: Date = parkingStartTime
        var endTime: Date = isCurrentParkingSpot ? .now : parkingEndTime

        if isCurrentParkingSpot {
            endTime = .now
        }

        var totalMinutes = calendar.dateComponents([.minute], from: startTime, to: endTime).minute ?? 0
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

extension ParkingSpot {
    func getAddress() {
        Task {
            if self.address.isEmpty {
                self.address = await getMKAdress()?.fullAddress ?? ""
            }
        }
    }

    func getMKAdress() async -> MKAddress? {
        let location = CLLocation(latitude: latitude, longitude: longitude)

        do {
            guard let mapItem = try await MKReverseGeocodingRequest(location: location)?.mapItems.first else { return nil }

            return mapItem.address
        } catch {
            // TODO: catch error
            dump(error)
            return nil
        }
    }
}
