//
//  ParkingSpotList.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 25/8/25.
//

import SwiftData
import SwiftUI

struct ParkingSpotList: View {
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \ParkingSpot.parkingStartTime, order: .reverse) var parkingSpots: [ParkingSpot]

    @Binding var trackingVehicle: Vehicle

    @State private var selectedParkingSpot: ParkingSpot? = nil

    @State private var searchText: String = ""
    @State private var startDateTimeFilter: Date = .distantPast
    @State private var endDateTimeFilter: Date = .now
    @State private var vehiclesFilter: Set<Vehicle> = []
    @State private var isShowingFilters: Bool = false
    @State private var isFiltering: Bool = false

    var searchResults: [ParkingSpot] {
        let filteredByDateTimePeriod = parkingSpots.filter {
            $0.parkingStartTime >= startDateTimeFilter &&
                $0.parkingStartTime <= endDateTimeFilter
        }
        let filteredByVehicles = filteredByDateTimePeriod.filter {
            if vehiclesFilter.isEmpty { return true }
            guard let vehicle = $0.vehicle else { return false }
            return vehiclesFilter.contains(vehicle)
        }

        if searchText.isEmpty {
            return filteredByVehicles
        } else {
            return filteredByVehicles.filter { $0.address.contains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            List(searchResults) { parkingSpot in
                ParkingSpotListRow(parkingSpot: parkingSpot) {
                    showInfo(for: parkingSpot)
                }
            }
            .searchable(text: $searchText, placement: .toolbar, prompt: "Address")
            .navigationTitle("Parking History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent()
            }
            .sheet(item: $selectedParkingSpot) { parkingSpot in
                ParkingSpotForm(parkingSpot: parkingSpot)
            }
            .sheet(isPresented: $isShowingFilters) {
                ParkingSpotListFilters(startDateTimeFilter: $startDateTimeFilter,
                                       endDateTimeFilter: $endDateTimeFilter,
                                       vehiclesFilter: $vehiclesFilter)
                    .presentationDetents([.medium, .large])
            }
            .onAppear {
                if startDateTimeFilter == .distantPast {
                    startDateTimeFilter = parkingSpots.map(\.parkingStartTime).min() ?? .now
                }
            }
            .onChange(of: startDateTimeFilter) { _, newValue in
                // I know this is a repeated code but it works so far. Future me, good luck
                if newValue == .distantPast {
                    startDateTimeFilter = parkingSpots.map(\.parkingStartTime).min() ?? .now
                }
            }
        }
    }
}

#Preview {
    ParkingSpotList(trackingVehicle: .constant(StoreProvider.sampleVehicle))
}

extension ParkingSpotList {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Close", systemImage: "xmark", role: .close, action: { dismiss() })
        }

        ToolbarItem(placement: .bottomBar) {
            Button("Filter by", systemImage: "line.3.horizontal.decrease", action: showFilters)
        }

        ToolbarSpacer(placement: .bottomBar)

        DefaultToolbarItem(kind: .search, placement: .bottomBar)
    }
}

extension ParkingSpotList {
    private func showInfo(for parkingSpot: ParkingSpot) {
        selectedParkingSpot = parkingSpot
    }

    private func showFilters() {
        isShowingFilters = true
    }
}
