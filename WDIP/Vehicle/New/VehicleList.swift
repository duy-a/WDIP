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
    
    @State private var isShowingVehicleForm: Bool = false

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
                .sheet(isPresented: $isShowingVehicleForm) {
                    Text("VHHVHVHVHV")
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
            Button {
                dismiss()
            } label: {
                Label("Cancel", systemImage: "xmark")
            }
        }

        ToolbarItem(placement: .primaryAction) {
            Button {
                addNewVehicle()
            } label: {
                Label("Add vehicle", systemImage: "plus")
            }
        }
    }
}

extension VehicleList {
    private func addNewVehicle() {
        isShowingVehicleForm = true
    }
    
    private func track(_ vehicle: Vehicle) {
        trackingVehicle = vehicle
        dismiss()
    }
    
    private func showInfo(for vehicle: Vehicle) {
        isShowingVehicleForm = true
    }
}
