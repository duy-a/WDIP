//
//  VehicleList.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 20/8/25.
//

import SwiftData
import SwiftUI

struct VehicleList: View {
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Vehicle.name) private var vehicles: [Vehicle]

    @Binding var trackingVehicle: Vehicle

    @State private var selectedVehicle: Vehicle? = nil
    @State private var isShowingNewVehicleForm: Bool = false

    var body: some View {
        NavigationStack {
            if vehicles.isEmpty {
                VehicleListEmpty(action: addNewVehicle)
            } else {
                List(vehicles) { vehicle in
                    VehicleListRow(vehicle: vehicle) {
                        track(vehicle)
                    } secondaryAction: {
                        showInfo(for: vehicle)
                    }
                }
                .navigationTitle("Your Vehicles")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarButtons()
                }
                .sheet(isPresented: $isShowingNewVehicleForm) {
                    VehicleForm()
                }
                .sheet(item: $selectedVehicle) { vehicle in
                    VehicleForm(vehicle: vehicle)
                }
            }
        }
    }
}

#Preview {
    VehicleList(trackingVehicle: .constant(StoreProvider.sampleVehicle))
        .modelContainer(StoreProvider.previewModelContainer)
}

extension VehicleList {
    @ToolbarContentBuilder
    func toolbarButtons() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", systemImage: "xmark", action: { dismiss() })
        }

        ToolbarItem(placement: .primaryAction) {
            Button("Add New Vehicle", systemImage: "plus", action: addNewVehicle)
        }
    }
}

extension VehicleList {
    private func addNewVehicle() {
        isShowingNewVehicleForm = true
    }

    private func track(_ vehicle: Vehicle) {
        trackingVehicle = vehicle
        dismiss()
    }

    private func showInfo(for vehicle: Vehicle) {
        selectedVehicle = vehicle
    }
}
