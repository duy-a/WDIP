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
                    DatePicker("End Date", selection: $endDateTimeFilter)
                }

                Section("Vehicle") {
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
                            .containerShape(.rect)
                        }
                        .buttonStyle(.plain)
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
    }
}

extension ParkingSpotListFilters {
    private func toggleVehicleFilter(vehicle: Vehicle) {
        if vehiclesFilter.contains(vehicle) {
            vehiclesFilter.remove(vehicle)
        } else {
            vehiclesFilter.insert(vehicle)
        }
    }
}
