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
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(parkingSpots) { spot in
                    Text(.now, format: .dateTime)
                }
                
                Text("When press on location, it will move the map there")
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
        }
    }
}

#Preview {
    ParkingSpotListView()
        .modelContainer(StoreProvider.previewModelContainer)
}
