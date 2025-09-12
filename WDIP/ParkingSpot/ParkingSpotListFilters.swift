//
//  ParkingSpotListFilters.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 3/9/25.
//

import SwiftData
import SwiftUI

struct ParkingSpotListFilters: View {
    @Query(sort: \Vehicle.name) private var vehicles: [Vehicle]

    @Binding var vehiclesFilter: Set<Vehicle>
    @Binding var startDateFilter: Date
    @Binding var endDateFilter: Date

    var body: some View {
        NavigationStack {
            Form {
                Section("Parking Period") {
                    DatePicker("Start Date", selection: $startDateFilter)
                    DatePicker("End Date", selection: $endDateFilter, in: startDateFilter ... .now)
                }

                Section {
                    ForEach(vehicles) { vehicle in
                        Button {
                            toggleVehicleFilter(vehicle: vehicle)
                        } label: {
                            HStack {
                                Label {
                                    Text(vehicle.name)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                } icon: {
                                    Image(systemName: vehicle.icon)
                                        .foregroundStyle(vehicle.uiColor)
                                }

                                Image(systemName: "checkmark")
                                    .foregroundStyle(.primary)
                                    .opacity(vehiclesFilter.contains(vehicle) ? 1 : 0)
                            }
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    HStack {
                        Text("Vehicles")
                        Spacer()
                        Button(vehiclesFilter.isEmpty ? "Select All" : "Deselect All", action: toggleAllVehicleSelection)
                    }
                }
            }
            .sheetToolbar("Filter") {
                toolbarContent
            }
        }
    }
}

// #Preview {
//    ParkingSpotListFilters(parkingSpots: [])
// }

extension ParkingSpotListFilters {
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Reset Filters", systemImage: "arrow.trianglehead.counterclockwise", action: triggerResetFilters)
        }
    }
}

extension ParkingSpotListFilters {
    private func triggerResetFilters() {
        startDateFilter = .distantPast
        endDateFilter = .now
    }

    private func toggleVehicleFilter(vehicle: Vehicle) {
        if vehiclesFilter.contains(vehicle) {
            vehiclesFilter.remove(vehicle)
        } else {
            vehiclesFilter.insert(vehicle)
        }
    }

    private func toggleAllVehicleSelection() {
        if vehiclesFilter.isEmpty {
            vehiclesFilter = Set(vehicles)
        } else {
            vehiclesFilter.removeAll()
        }
    }
}
