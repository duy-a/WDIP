//
//  ParkingSpotList.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 12/9/25.
//

import SwiftData
import SwiftUI

struct ParkingSpotList: View {
    @Binding var trackingVehicle: Vehicle

    @State private var vehiclesFilter: Set<Vehicle> = []
    @State private var startDateFilter: Date = .distantPast
    @State private var endDateFilter: Date = .now

    @State private var isShowingFilters: Bool = false

    var body: some View {
        NavigationStack {
            ParkingSpotListFiltered(vehicles: vehiclesFilter,
                                    startDate: startDateFilter,
                                    endDate: endDateFilter)
                .sheetToolbar("Parking History") {
                    toolbarContent
                }
                .sheet(isPresented: $isShowingFilters) {
                    ParkingSpotListFilters(vehiclesFilter: $vehiclesFilter,
                                           startDateFilter: $startDateFilter,
                                           endDateFilter: $endDateFilter)
                }
        }
        .onAppear {
            vehiclesFilter.insert(trackingVehicle)
            let earliestDate = trackingVehicle.parkingSpots?
                .map { $0.parkingStartTime }
                .min()

            if let earliestDate {
                startDateFilter = earliestDate
            }
        }
    }
}

// #Preview {
//    ParkingSpotList()
// }

extension ParkingSpotList {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button("Filter by", systemImage: "line.3.horizontal.decrease", action: showFilters)
        }

        ToolbarSpacer(placement: .bottomBar)

        DefaultToolbarItem(kind: .search, placement: .bottomBar)
    }
}

extension ParkingSpotList {
    private func searchByAddress(text: String) {
        //
    }

    private func showFilters() {
        isShowingFilters = true
    }
}
