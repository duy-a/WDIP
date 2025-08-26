//
//  ParkingSpotForm.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 26/8/25.
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
                        if parkingSpot.isCurrentParkingSpot {
                            Text("Parked Here")
                        } else {
                            Text(parkingSpot.parkingEndTime, format: .dateTime)
                        }
                    } icon: {
                        Image(systemName: "clock.badge")
                    }
                } header: {
                    Text("Parking time")
                } footer: {
                    Text("Duration: \(parkingSpot.parkingDuration)")
                }
            }
            .toolbar {
                toolbarContent()
            }
            .alert("Are you sure?", isPresented: $isShowingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive, action: delete)
            }
            .onAppear(perform: onStart)
        }
    }
}

#Preview {
    ParkingSpotForm(parkingSpot: StoreProvider.sampleParkingSpot1)
}

extension ParkingSpotForm {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button("Cancel", systemImage: "xmark", role: .cancel, action: { dismiss() })
        }

        if !parkingSpot.isCurrentParkingSpot {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Delete", systemImage: "trash", role: .destructive, action: { isShowingDeleteAlert = true })
                    .tint(.red)
            }
        }

        ToolbarSpacer(.fixed, placement: .topBarTrailing)

        ToolbarItem(placement: .topBarTrailing) {
            Button("Directions", systemImage: "arrow.turn.left.up", action: parkingSpot.getDirectionsInMaps)
        }
    }
}

extension ParkingSpotForm {
    private func onStart() {
        parkingSpot.getAddress()
        mapCameraPosition = .camera(MapCamera(centerCoordinate: parkingSpot.coordinates, distance: 1000))
    }

    private func delete() {
        modelContext.delete(parkingSpot)
        dismiss()
    }
}
