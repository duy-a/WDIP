//
//  StoreProvider+Migration.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 11/9/25.
//

import SwiftData
import SwiftUI

extension StoreProvider {
    func migrate() {
        migratteToVersion031()
    }
}

extension StoreProvider {
    /// Migration will handle ParkingSpot.isCurrentParkingSpot variable being changed from a computed property to a var
    private func migratteToVersion031() {
        do {
            let descriptor = FetchDescriptor<Vehicle>()
            let vehicles = try modelContainer.mainContext.fetch(descriptor)

            for vehicle in vehicles {
                if vehicle.isParked {
                    if let toUpdateActiveParkingSpot = vehicle.parkingSpots?
                        .max(by: { $0.parkingStartTime < $1.parkingStartTime })
                    {
                        if toUpdateActiveParkingSpot.isCurrentParkingSpot == false {
                            toUpdateActiveParkingSpot.isCurrentParkingSpot = true
                        } else {
                            vehicle.isParked = false
                        }
                    } else {
                        // No parking spots at all, reset state
                        vehicle.isParked = false
                    }
                }
            }

            try modelContainer.mainContext.save()
        } catch {
            print("Migration error: \(error.localizedDescription)")
        }
    }
}
