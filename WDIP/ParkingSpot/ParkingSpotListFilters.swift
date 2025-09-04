//
//  ParkingSpotListFilters.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 3/9/25.
//

import SwiftData
import SwiftUI

struct ParkingSpotListFilters: View {
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Vehicle.name) private var vehicles: [Vehicle]

    @Binding var startDateTimeFilter: Date
    @Binding var endDateTimeFilter: Date
    @Binding var vehiclesFilter: Set<Vehicle>

    var body: some View {
        NavigationStack {
            Form {
                Section("Parking Period") {
                    DatePicker("Start Date", selection: $startDateTimeFilter)
                    DatePicker("End Date", selection: $endDateTimeFilter, in: startDateTimeFilter ... .now)
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
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Image(systemName: "checkmark")
                                    .foregroundStyle(.primary)
                                    .opacity(vehiclesFilter.contains(vehicle) ? 1 : 0)
                            }
                            .containerShape(.rect)
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
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent()
            }
        }
    }
}

// #Preview {
//    ParkingSpotListFilters(parkingSpots: [])
// }

extension ParkingSpotListFilters {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Close", systemImage: "xmark", role: .close, action: { dismiss() })
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button("Reset Filters", systemImage: "arrow.trianglehead.counterclockwise", action: triggerResetFilters)
        }
    }
}

extension ParkingSpotListFilters {
    private func triggerResetFilters() {
        startDateTimeFilter = .distantPast
        // the rest of filters will be reset by parent, whacky? yes, but I don't want to spend more time on this
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
