//
//  ParkingSpotListRow.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 14/9/25.
//

import SwiftUI

struct ParkingSpotListRow: View {
    var parkingSpot: ParkingSpot

    @State private var showInfo: Bool = false

    var body: some View {
        HStack {
            Label {
                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        Text(parkingSpot.vehicle?.name ?? "")
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundStyle(.secondary)
                            .fontWeight(.semibold)

                        Spacer()

                        if parkingSpot.parkEndTime == nil {
                            Text("Active")
                                .foregroundStyle(.green)
                        } else {
                            Text(parkingSpot.parkStartTime, format: .dateTime)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .font(.footnote)

                    if parkingSpot.address.isEmpty {
                        Text("Getting adress information ...")
                            .italic()
                    } else {
                        Text(parkingSpot.address)
                    }
                }
            } icon: {
                Image(systemName: parkingSpot.vehicle?.icon ?? "questionmark")
                    .foregroundStyle(parkingSpot.vehicle?.uiColor ?? .primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button("Show Vehicle Info", systemImage: "info") {
                showInfo = true
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.glass)
        }
        .onAppear {
            // Get Parking spot adress
        }
        .sheet(isPresented: $showInfo) {
            ParkingSpotForm(parkingSpot: parkingSpot)
        }
    }
}
