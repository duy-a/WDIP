//
//  ParkingSpotListFiltered.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 12/9/25.
//

import SwiftData
import SwiftUI

struct ParkingSpotListFiltered: View {
    @Query private var parkingSpots: [ParkingSpot]

    init(vehicles: Set<Vehicle>, startDate: Date, endDate: Date, searchText: String) {
        let vehicleIds = vehicles.map { $0.persistentModelID }

        if searchText.isEmpty {
            self._parkingSpots = Query(
                filter: #Predicate { spot in

                    if let vehicle = spot.vehicle {
                        vehicleIds.contains(vehicle.persistentModelID) &&
                            spot.parkingStartTime <= endDate &&
                            spot.parkingEndTime >= startDate
                    } else {
                        false
                    }

                },
                sort: \.parkingStartTime,
                order: .reverse
            )
        } else {
            self._parkingSpots = Query(
                filter: #Predicate { spot in

                    if let vehicle = spot.vehicle {
                        vehicleIds.contains(vehicle.persistentModelID) &&
                            spot.parkingStartTime <= endDate &&
                            spot.parkingEndTime >= startDate &&
                            spot.address.localizedStandardContains(searchText)
                    } else {
                        false
                    }

                },
                sort: \.parkingStartTime,
                order: .reverse
            )
        }
    }

    var body: some View {
        List(parkingSpots) { parkingSpot in
            ParkingSpotListRow(parkingSpot: parkingSpot)
        }
    }
}
