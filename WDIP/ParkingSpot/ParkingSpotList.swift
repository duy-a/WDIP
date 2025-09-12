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

    @State private var searchText: String = ""
    @State private var debouncedSearchText: String = ""
    @State private var isShowingFilters: Bool = false

    var body: some View {
        NavigationStack {
            ParkingSpotListFiltered(vehicles: vehiclesFilter,
                                    startDate: startDateFilter,
                                    endDate: endDateFilter,
                                    searchText: debouncedSearchText)
                .sheetToolbar("Parking History") {
                    toolbarContent
                }
                .searchable(text: $searchText, prompt: "Address")
                .sheet(isPresented: $isShowingFilters) {
                    ParkingSpotListFilters(vehiclesFilter: $vehiclesFilter,
                                           startDateFilter: $startDateFilter,
                                           endDateFilter: $endDateFilter)
                }
                .task(id: searchText) {
                    await debounceSearch()
                }
        }
        .onAppear {
            handleOnAppear()
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
    private func handleOnAppear() {
        vehiclesFilter.insert(trackingVehicle)
        let earliestDate = trackingVehicle.parkingSpots?
            .map { $0.parkingStartTime }
            .min()

        if let earliestDate {
            startDateFilter = earliestDate
        }
    }

    private func debounceSearch() async {
        do {
            try await Task.sleep(for: .seconds(0.3))
            if !Task.isCancelled {
                debouncedSearchText = searchText
            }
        } catch {
            print("Task cancelled or error: \(error)")
        }
    }

    private func showFilters() {
        isShowingFilters = true
    }
}
