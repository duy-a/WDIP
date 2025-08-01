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

    @State private var selectedParkingSpot: ParkingSpot? = nil
    @State private var isShowingParkingSpotInfo: Bool = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(parkingSpots) { parkingSpot in
                    Button {
                        selectedParkingSpot = parkingSpot
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 2) {
                                    Text(parkingSpot.parkingStartTime, format: .dateTime)
                                    

                                    if !parkingSpot.isCurrentParkingSpot {
                                        Text("-")
                                        Text(parkingSpot.parkingEndTime, format: .dateTime)

                                        Spacer()

                                        Text(parkingSpot.parkingDuration)
                                    } else {
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
                ParkingSpotInfoView(parkingSpot: parkingSpot)
            }
        }
    }
}

#Preview {
    ParkingSpotListView()
        .modelContainer(StoreProvider.previewModelContainer)
}
