//
//  ParkingSpotListFiltered.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 13/9/25.
//

import SwiftData
import SwiftUI

struct ParkingSpotListFiltered<Content: View>: View {
    @Query private var parkingSpot: [ParkingSpot]

    var content: (ParkingSpot) -> Content

    init(
        startDate: Date,
        endDate: Date,
        @ViewBuilder content: @escaping (ParkingSpot) -> Content)
    {
        let predicate = #Predicate<ParkingSpot> { spot in
            if let parkEndTime = spot.parkEndTime {
                spot.parkStartTime <= endDate && parkEndTime >= startDate
            } else {
                spot.parkStartTime <= endDate && spot.parkEndTime == nil
            }
        }
        let sort = [
            SortDescriptor(\ParkingSpot.parkStartTime, order: .reverse),
            SortDescriptor(\ParkingSpot.createdAt, order: .reverse)
        ]

        self._parkingSpot = Query(filter: predicate, sort: sort)
        self.content = content
    }

    var body: some View {
        List(parkingSpot) { spot in
            content(spot)
        }
    }
}
