//
//  ParkingSpotListView.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 31/7/25.
//

import SwiftUI
import SwiftData

struct ParkingSpotListView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \ParkingSpot.parkingDate)
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
                        Text(.now, format: .dateTime)
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
                        Label("Close List" ,systemImage: "xmark")
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
