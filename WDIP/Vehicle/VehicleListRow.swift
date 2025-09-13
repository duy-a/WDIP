//
//  VehicleListRow.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 13/9/25.
//

import SwiftUI

struct VehicleListRow: View {
    @Environment(\.dismiss) private var dismiss

    var vehicle: Vehicle

    @Binding var trackingVehicle: Vehicle?

    @State private var isShowingVehicleInfo: Bool = false

    var body: some View {
        HStack {
            Label {
                Text(vehicle.name)
            } icon: {
                Image(systemName: vehicle.icon)
                    .foregroundStyle(vehicle.uiColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button("Track Vehicle", systemImage: "location") {
                trackingVehicle = vehicle
                dismiss()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.glassProminent)

            Button("Show Vehicle Info", systemImage: "info") {
                isShowingVehicleInfo = true
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.glass)
        }
        .sheet(isPresented: $isShowingVehicleInfo) {
            VehicleForm(vehicle: vehicle) {
                trackingVehicle = nil
            }
        }
    }
}
