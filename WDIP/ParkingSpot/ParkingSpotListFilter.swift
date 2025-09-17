//
//  ParkingSpotListFilter.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 14/9/25.
//

import SwiftData
import SwiftUI

struct ParkingSpotListFilter: View {
    @Binding var vehiclesFilter: Set<Vehicle>
    @Binding var startDateFilter: Date
    @Binding var endDateFilter: Date

    var onReset: () -> Void

    @Query(sort: \Vehicle.name) private var vehicles: [Vehicle]

    var body: some View {
        NavigationStack {
            Form {
                Section("Date Range") {
                    DatePicker("Start Date", selection: $startDateFilter, in: ...Date.now)
                    DatePicker("End Date", selection: $endDateFilter, in: ...Date.now)
                }

                Section {
                    ForEach(vehicles) { vehicle in
                        Button {
                            toggleVehicleSelection(vehicle: vehicle)
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
            .onAppear {
                if vehiclesFilter.isEmpty {
                    vehiclesFilter = Set(vehicles)
                }
            }
            .sheetToolbar("Filters") {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset Filters", systemImage: "arrow.trianglehead.counterclockwise") {
                        onReset()
                    }
                }
            }
        }
    }
}

extension ParkingSpotListFilter {
    private func toggleVehicleSelection(vehicle: Vehicle) {
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
