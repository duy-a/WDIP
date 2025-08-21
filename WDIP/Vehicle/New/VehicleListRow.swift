//
//  VehicleListRow.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 21/8/25.
//

import SwiftData
import SwiftUI

struct VehicleListRow: View {
    @Bindable var vehicle: Vehicle

    var primaryAction: () -> Void
    var secondaryAction: () -> Void

    var body: some View {
        HStack {
            Label {
                Text(vehicle.name)
            } icon: {
                Image(systemName: vehicle.icon)
                    .foregroundStyle(vehicle.uiColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button("Track Vehicle", systemImage: "location", action: primaryAction)
                .labelStyle(.iconOnly)
                .buttonStyle(.glassProminent)

            Button("Show Vehicle Info", systemImage: "info", action: secondaryAction)
                .labelStyle(.iconOnly)
                .buttonStyle(.glass)
        }
    }
}

#Preview {
    List {
        VehicleListRow(vehicle: StoreProvider.sampleVehicle) {
            //
        } secondaryAction: {
            //
        }
    }
}
