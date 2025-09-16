//
//  ParkingSpotForm.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 15/9/25.
//

import MapKit
import SwiftData
import SwiftUI

struct ParkingSpotForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var parkingSpot: ParkingSpot

    @State private var mapCameraPosition: MapCameraPosition = .automatic
    @State private var isShowingDeleteAlert: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Notes", text: $parkingSpot.notes)
            }
            .task {
                if parkingSpot.address.isEmpty {
                    parkingSpot.address = await ParkingSpot.getAddressBy(latitude: parkingSpot.latitude,
                                                                         longitude: parkingSpot.longitude)
                }
            }
            .sheetToolbar("Parking Info") {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Delete", systemImage: "trash", action: { isShowingDeleteAlert = true })
                        .tint(.red)
                }

                ToolbarSpacer(.fixed, placement: .topBarTrailing)

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Directions", systemImage: "arrow.turn.left.up", action: {})
                }
            }
            .alert("Are you sure?", isPresented: $isShowingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive, action: deleteParkingSpot)
            }
        }
    }
}

extension ParkingSpotForm {
    private func deleteParkingSpot() {
        if let vehicle = parkingSpot.vehicle,
           vehicle.isParked,
           vehicle.currentParkingSpot == parkingSpot
        {
            parkingSpot.vehicle?.isParked = false
        }

        modelContext.delete(parkingSpot)
        dismiss()
    }
}
