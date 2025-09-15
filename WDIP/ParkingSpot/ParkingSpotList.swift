//
//  ParkingSpotList.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 13/9/25.
//

import SwiftData
import SwiftUI

/// Copying @Query to local Array due to UI updating slowly when using predicated directy at @Query
/// This is happeining when enabled SwiftData + Cloudkit
/// If I stumble upon the solution i will update this, but for now this works and have a great reactivity
struct ParkingSpotList: View {
    @Query(sort: [
        SortDescriptor(\ParkingSpot.parkStartTime, order: .reverse),
        SortDescriptor(\ParkingSpot.createdAt, order: .reverse)
    ])
    private var parkingSpots: [ParkingSpot]

    @State private var localParkingSpotsCopy: [ParkingSpot] = []

    @State private var vehiclesFilter: Set<Vehicle> = []
    @State private var startDateFilter: Date = Calendar.current.date(byAdding: .month, value: -1, to: .now)!
    @State private var endDateFilter: Date = .now

    @State private var isShowingFilters: Bool = false

    @State private var debounceTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            List(localParkingSpotsCopy) { spot in
                ParkingSpotListRow(parkingSpot: spot)
            }
            .refreshable {
                applyFilters()
            }
            .onAppear {
                localParkingSpotsCopy = parkingSpots
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
                                      onApply: applyFilters)
            }
        }
    }

    private func applyFilters() {
        localParkingSpotsCopy = parkingSpots

        localParkingSpotsCopy = localParkingSpotsCopy
            .filter { spot in
                let parkEndTime = spot.parkEndTime ?? .distantFuture
                let startBeforeEnd = spot.parkStartTime <= endDateFilter
                let endAfterStart = parkEndTime >= startDateFilter
                let matchedVehicles = spot.vehicle.map { vehiclesFilter.contains($0) } ?? false

                return matchedVehicles && startBeforeEnd && endAfterStart
            }
    }
}
