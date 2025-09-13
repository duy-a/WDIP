//
//  ParkingSpotList.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 13/9/25.
//

import SwiftData
import SwiftUI

struct ParkingSpotList: View {
    @State private var startDate: Date = .distantPast
    @State private var endDate: Date = .now

    var body: some View {
        NavigationStack {
            ParkingSpotListFiltered(startDate: startDate, endDate: endDate) { spot in
                VStack {
                    Text(spot.createdAt, format: .dateTime)
                    if spot.parkEndTime == nil {
                        Text("current")
                    }
                }
            }
            .sheetToolbar("Parking History")
        }
    }
}
