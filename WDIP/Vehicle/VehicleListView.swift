//
//  VehicleListView.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 23/7/25.
//

import SwiftData
import SwiftUI

struct VehicleListView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedVehicleTracking: Vehicle

    @Query(sort: \Vehicle.name)
    private var vehicle: [Vehicle]

    @State private var isPresentedVehicleForm: Bool = false
    @State private var selectedVehicleInfo: Vehicle? = nil

    var body: some View {
        NavigationStack {
            Group {
                if vehicle.count <= 0 {
                    ContentUnavailableView {
                        Label("Vehicle Icon", systemImage: "car.badge.gearshape")
                    } description: {
                        Text("We need at least 1 vehicle to track. Add a new vehicle now by pressing a button below")
                            .multilineTextAlignment(.center)
                    } actions: {
                        Button {
                            isPresentedVehicleForm = true
                        } label: {
                            Label("Add new vehicle", systemImage: "car")
                                .font(.title2)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.glassProminent)
                        .controlSize(.extraLarge)
                    }
                } else {
                    List {
                        ForEach(vehicle) { vehicle in
                            HStack {
                                Button {
                                    selectedVehicleTracking = vehicle
                                    dismiss()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: vehicle.icon)
                                            .foregroundColor(PickerColors.getUIColor(color: vehicle.color))

                                        Text(vehicle.name)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(.rect)
                                }
                                .buttonStyle(.plain)

                                Button {
                                    selectedVehicleInfo = vehicle
                                } label: {
                                    Label("Vehicle information", systemImage: "info.circle")
                                        .labelStyle(.iconOnly)
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Your Vehicle")
            .sheet(isPresented: $isPresentedVehicleForm) {
                VehicleFormView()
            }
            .sheet(item: $selectedVehicleInfo) { vehicle in
                VehicleFormView(vehicle: vehicle)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close vehicle list", systemImage: "xmark")
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isPresentedVehicleForm = true
                    } label: {
                        Label("Add new vehicle", systemImage: "plus")
                    }
                }
            }
            .onAppear {}
        }
    }
}

#Preview {
    VehicleListView(selectedVehicleTracking: .constant(Vehicle()))
        .modelContainer(for: Vehicle.self, inMemory: true)
}
