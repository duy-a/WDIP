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
    private func migratteToVersion031() {
        do {
            let descriptor = FetchDescriptor<Vehicle>()
            let vehicles = try modelContainer.mainContext.fetch(descriptor)

            for vehicle in vehicles {
                if vehicle.isParked {
                    let toUpdateActiveParkingSpot = vehicle.parkingSpots?
                        .sorted { $0.parkingStartTime > $1.parkingStartTime }
                        .first

                    if let toUpdateActiveParkingSpot {
                        toUpdateActiveParkingSpot.isCurrentParkingSpot = true
                    } else {
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
