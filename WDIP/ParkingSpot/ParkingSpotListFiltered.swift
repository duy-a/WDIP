//
//  ParkingSpotListFiltered.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 15/9/25.
//

import SwiftData
import SwiftUI

struct ParkingSpotListFiltered<Content: View>: View {
    @Query private var parkingSpots: [ParkingSpot]

    var content: (ParkingSpot) -> Content

    init(startDate: Date,
         endDate: Date,
         vehicles: Set<Vehicle>,
         @ViewBuilder content: @escaping (ParkingSpot) -> Content)
    {
        let vehicleIds = vehicles.map { $0.id }

        let startBeforeEnd = #Predicate<ParkingSpot> { spot in
            spot.parkStartTime <= endDate
        }
        let endAfterStart = #Predicate<ParkingSpot> { spot in
            if let parkEndTime = spot.parkEndTime {
                parkEndTime >= startDate
            } else {
                true
            }
        }
        let inVehicles = #Predicate<ParkingSpot> { spot in
            if let vehicle = spot.vehicle {
                vehicleIds.contains(vehicle.id)
            } else {
                false
            }
        }

        let combinedPredicate = #Predicate<ParkingSpot> {
            (inVehicles.evaluate($0) || vehicleIds.isEmpty)
            &&
            startBeforeEnd.evaluate($0)
            &&
            endAfterStart.evaluate($0)
        }
        
        let sort = [
            SortDescriptor(\ParkingSpot.parkStartTime, order: .reverse),
            SortDescriptor(\ParkingSpot.createdAt, order: .reverse)
        ]

        self._parkingSpots = Query(filter: combinedPredicate, sort: sort)
        self.content = content
    }

    var body: some View {
        List(parkingSpots) { spot in
            content(spot)
        }
    }
}
