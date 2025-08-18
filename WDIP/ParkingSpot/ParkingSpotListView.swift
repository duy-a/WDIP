//
//  ParkingSpotListView.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 31/7/25.
//

import MapKit
import SwiftData
import SwiftUI

struct ParkingSpotListView: View {
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \ParkingSpot.parkingStartTime, order: .reverse)
    private var parkingSpots: [ParkingSpot]

    @Binding var mapCameraPosition: MapCameraPosition

    @State private var selectedParkingSpot: ParkingSpot? = nil
    @State private var isShowingParkingSpotInfo: Bool = false

    @State private var callToDismiss: Bool = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(parkingSpots) { parkingSpot in
                    Button {
                        selectedParkingSpot = parkingSpot
                    } label: {
                        HStack {
                            if parkingSpot.vehicle != nil {
                                let vehicle = parkingSpot.vehicle!

                                ParkingSpotLabel(icon: PickerIcons(rawValue: vehicle.icon)!, color: PickerColors(rawValue: vehicle.color)!)
                            } else {
                                Label("Parking sign", systemImage: "parkingsign.square.fill")
                                    .labelStyle(.iconOnly)
                                    .foregroundStyle(.blue)
                            }

                            Spacer()

                            VStack(alignment: .leading, spacing: 5) {
                                HStack(spacing: 2) {
                                    Text(parkingSpot.parkingStartTime, format: .dateTime.day().month().year())

                                    if parkingSpot.isCurrentParkingSpot {
                                        Spacer()
                                        Text("Parked here")
                                    }
                                }

                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .italic()

                                Text(parkingSpot.address)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Spacer()

                            Label("Parking Spot Info", systemImage: "chevron.right")
                                .labelStyle(.iconOnly)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Parking Spots History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close List", systemImage: "xmark")
                    }
                }
            }
            .sheet(item: $selectedParkingSpot) { parkingSpot in
                ParkingSpotInfoView(parkingSpot: parkingSpot, mapCameraPosition: $mapCameraPosition) {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    let mapCenterPosition: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)

    ParkingSpotListView(mapCameraPosition: .constant(mapCenterPosition),)
        .modelContainer(StoreProvider.previewModelContainer)
}
