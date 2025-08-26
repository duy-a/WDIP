//
//  ParkingSpotList.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 25/8/25.
//

import SwiftData
import SwiftUI

struct ParkingSpotList: View {
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \ParkingSpot.parkingStartTime, order: .reverse) var parkingSpots: [ParkingSpot]

    @Binding var trackingVehicle: Vehicle

    @State private var selectedParkingSpot: ParkingSpot? = nil

    @State private var searchText: String = ""

    var searchResults: [ParkingSpot] {
        if searchText.isEmpty {
            return parkingSpots
        } else {
            return parkingSpots.filter { $0.address.contains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            List(searchResults) { parkingSpot in
                ParkingSpotListRow(parkingSpot: parkingSpot) {
                    showInfo(for: parkingSpot)
                }
            }
            .searchable(text: $searchText, placement: .toolbar, prompt: "Address")
            .navigationTitle("Parking History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent()
            }
            .sheet(item: $selectedParkingSpot) { parkingSpot in
                ParkingSpotForm(parkingSpot: parkingSpot)
            }
        }
    }
}

#Preview {
    ParkingSpotList(trackingVehicle: .constant(StoreProvider.sampleVehicle))
}

extension ParkingSpotList {
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Close", systemImage: "xmark", role: .close, action: { dismiss() })
        }

        ToolbarItem(placement: .bottomBar) {
            Button("Filter by", systemImage: "line.3.horizontal.decrease") {
                //
            }
        }

        ToolbarSpacer(placement: .bottomBar)

        DefaultToolbarItem(kind: .search, placement: .bottomBar)
    }
}

extension ParkingSpotList {
    private func showInfo(for parkingSpot: ParkingSpot) {
        selectedParkingSpot = parkingSpot
    }
}
