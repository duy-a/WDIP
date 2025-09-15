//
//  ParkingSpotList.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 13/9/25.
//

import SwiftData
import SwiftUI

struct ParkingSpotList: View {
    var trackingVehicle: Vehicle? = nil

    @State private var vehiclesFilter: Set<Vehicle> = []
    @State private var startDateFilter: Date = Calendar.current.date(byAdding: .month, value: -1, to: .now)!
    @State private var endDateFilter: Date = .now

    @State private var isShowingFilters: Bool = false

    var body: some View {
        NavigationStack {
            ParkingSpotListFiltered(startDate: startDateFilter,
                                    endDate: endDateFilter,
                                    vehicles: vehiclesFilter)
            { spot in
                ParkingSpotListRow(parkingSpot: spot)
            }
            .onAppear {
                setInitialFilters()
            }
            .sheetToolbar("Parking History") {
                ToolbarItem(placement: .bottomBar) {
                    Button("Filter by", systemImage: "line.3.horizontal.decrease") {
                        isShowingFilters = true
                    }
                }

                ToolbarSpacer(.flexible, placement: .bottomBar)
            }
            .sheet(isPresented: $isShowingFilters) {
                ParkingSpotListFilter(vehiclesFilter: $vehiclesFilter,
                                      startDateFilter: $startDateFilter,
                                      endDateFilter: $endDateFilter,
                                      onReset: setInitialFilters)
            }
        }
    }
}

extension ParkingSpotList {
    private func setInitialFilters() {
        if let trackingVehicle {
            vehiclesFilter.removeAll()
            vehiclesFilter.insert(trackingVehicle)
        } else {
            vehiclesFilter = []
        }

        if let earliestDate = trackingVehicle?.parkingSpots?.compactMap(\.parkStartTime).min() {
            startDateFilter = earliestDate
        } else {
            startDateFilter = Calendar.current.date(byAdding: .month, value: -1, to: .now)!
        }

        endDateFilter = .now
    }
}
