//
//  ParkingSpotListRow.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 25/8/25.
//

import SwiftData
import SwiftUI

struct ParkingSpotListRow: View {
    @Bindable var parkingSpot: ParkingSpot

    @State private var showInfo: Bool = false

    var vehicle: Vehicle {
        parkingSpot.vehicle ?? Vehicle(name: "???", icon: "questionmark", color: "gray")
    }

    var body: some View {
        HStack {
            Label {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(parkingSpot.parkingStartTime, format: .dateTime)
                            .foregroundStyle(.secondary)

                        Spacer()

                        if parkingSpot.isCurrentParkingSpot {
                            Text("Active")
                                .foregroundStyle(.green)
                        }
                    }
                    .font(.footnote)

                    if parkingSpot.address.isEmpty {
                        Text("Getting street information ...")
                            .italic()
                    } else {
                        Text(parkingSpot.address)
                    }
                }
            } icon: {
                Image(systemName: vehicle.icon)
                    .foregroundStyle(vehicle.uiColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button("Show Vehicle Info", systemImage: "info") {
                showInfo = true
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.glass)
        }
        .onAppear(perform: parkingSpot.getAddress)
        .sheet(isPresented: $showInfo) {
            ParkingSpotForm(parkingSpot: parkingSpot)
        }
    }
}
