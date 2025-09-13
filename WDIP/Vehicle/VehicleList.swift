//
//  VehicleList.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 13/9/25.
//

import SwiftData
import SwiftUI

struct VehicleList: View {
    @Query(sort: \Vehicle.name) var vehicles: [Vehicle]

    @Binding var trackingVehicle: Vehicle?

    @State private var isShowingVehicleForm: Bool = false

    var body: some View {
        NavigationStack {
            if vehicles.isEmpty {
                VehicleListEmpty()
            } else {
                List(vehicles) { vehicle in
                    VehicleListRow(vehicle: vehicle, trackingVehicle: $trackingVehicle)
                }
                .sheetToolbar("Your vehicles") {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add new vehicle", systemImage: "plus", role: .confirm) {
                            isShowingVehicleForm = true
                        }
                    }
                }
                .sheet(isPresented: $isShowingVehicleForm) {
                    VehicleForm()
                }
            }
        }
    }
}

extension VehicleList {}
