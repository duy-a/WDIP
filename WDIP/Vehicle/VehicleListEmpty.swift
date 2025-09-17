//
//  VehicleListEmpty.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 13/9/25.
//

import SwiftUI

struct VehicleListEmpty: View {
    @State private var isShowingVehicleForm: Bool = false

    var body: some View {
        ContentUnavailableView {
            Label("No vehicles?", systemImage: "car.badge.gearshape")
        } description: {
            Text("Add a vehicle now to start tracking")
        } actions: {
            Button("Add vehicle", systemImage: "plus") {
                isShowingVehicleForm = true
            }
            .buttonStyle(.glassProminent)
            .controlSize(.extraLarge)
        }
        .sheet(isPresented: $isShowingVehicleForm) {
            VehicleForm()
        }
    }
}
