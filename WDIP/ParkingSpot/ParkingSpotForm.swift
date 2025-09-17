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

    var parkingDuration: String {
        guard let parkingEndTime = parkingSpot.parkingEndTime else { return "" }
        let interval = Int(parkingEndTime.timeIntervalSince(parkingSpot.parkingStartTime))

        let days = interval / 86400
        let hours = (interval % 86400) / 3600
        let minutes = (interval % 3600) / 60
        let seconds = interval % 60

        if days > 0 {
            // Format as "Xd hh:mm:ss"
            return String(format: "%dd %02d:%02d:%02d", days, hours, minutes, seconds)
        } else {
            // Format as "hh:mm:ss"
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Map") {
                    Map(position: $mapCameraPosition, interactionModes: []) {
                        Marker(coordinate: parkingSpot.coordinates) {
                            Text("Parking Spot")
                        }
                    }
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .cornerRadius(15)

                    Text(parkingSpot.address)
                }

                Section("Notes") {
                    TextField("Notes", text: $parkingSpot.notes)
                }

                Section {
                    Label {
                        Text(parkingSpot.parkingStartTime, format: .dateTime)
                    } icon: {
                        Image(systemName: "clock")
                    }

                    Label {
                        if let parkingEndTime = parkingSpot.parkingEndTime {
                            Text(parkingEndTime, format: .dateTime)
                        } else {
                            Text("Currently Parked Here")
                        }
                    } icon: {
                        Image(systemName: "clock.badge")
                    }
                } header: {
                    Text("Parking time")
                } footer: {
                    Text("Total Duration: \(parkingDuration)")
                }
            }
            .task {
                if parkingSpot.address.isEmpty {
                    parkingSpot.address = await LocationManager.getAddressBy(coordinates: parkingSpot.coordinates)
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
