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
         searchText: String,
         @ViewBuilder content: @escaping (ParkingSpot) -> Content)
    {
        let vehicleIds = vehicles.map { $0.uuid }

        let startBeforeEnd = #Predicate<ParkingSpot> { spot in
            spot.parkingStartTime <= endDate
        }
        let endAfterStart = #Predicate<ParkingSpot> { spot in
            if let parkEndTime = spot.parkingEndTime {
                parkEndTime >= startDate
            } else {
                true
            }
        }
        let inVehicles = #Predicate<ParkingSpot> { spot in
            if let vehicle = spot.vehicle {
                vehicleIds.contains(vehicle.uuid)
            } else {
                false
            }
        }
        let searchByAddress = #Predicate<ParkingSpot> { spot in
            searchText.isEmpty || spot.address.localizedStandardContains(searchText)
        }

        let combinedPredicate = #Predicate<ParkingSpot> {
            (inVehicles.evaluate($0) || vehicleIds.isEmpty)
            &&
            startBeforeEnd.evaluate($0)
            &&
            endAfterStart.evaluate($0)
            &&
            searchByAddress.evaluate($0)
        }
        
        let sort = [
            SortDescriptor(\ParkingSpot.parkingStartTime, order: .reverse),
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
