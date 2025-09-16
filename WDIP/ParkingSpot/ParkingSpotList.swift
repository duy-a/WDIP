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
    @State private var searchText: String = ""
    @State private var debouncedSearchText = ""

    @State private var debounceTask: Task<Void, Never>? = nil

    var body: some View {
        NavigationStack {
            ParkingSpotListFiltered(startDate: startDateFilter,
                                    endDate: endDateFilter,
                                    vehicles: vehiclesFilter,
                                    searchText: debouncedSearchText)
            { spot in
                ParkingSpotListRow(parkingSpot: spot)
            }
            .onAppear {
                setInitialFilters()
            }
            .searchable(text: $searchText, prompt: "Address")
            .onChange(of: searchText) {
                debounceTask?.cancel()
                debounceTask = Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second debounce
                    guard !Task.isCancelled else { return }
                    debouncedSearchText = searchText
                }
            }
            .sheetToolbar("Parking History") {
                ToolbarItem(placement: .bottomBar) {
                    Button("Filter by", systemImage: "line.3.horizontal.decrease") {
                        isShowingFilters = true
                    }
                }
                ToolbarSpacer(.flexible, placement: .bottomBar)
                DefaultToolbarItem(kind: .search, placement: .bottomBar)
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
