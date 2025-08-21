//
//  VehicleListEmpty.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 21/8/25.
//

import SwiftUI

struct VehicleListEmpty: View {
    var action: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("No vehicles?", systemImage: "car.badge.gearshape")
        } description: {
            Text("Add a vehicle now to start tracking")
        } actions: {
            Button {
                //
            } label: {
                Label("Add vehicle", systemImage: "plus")
            }
            .buttonStyle(.glassProminent)
            .controlSize(.extraLarge)
        }
    }
}

#Preview {
    VehicleListEmpty {
        //
    }
}
