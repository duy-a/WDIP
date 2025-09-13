//
//  ParkingMap.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 13/9/25.
//

import MapKit
import SwiftUI

struct ParkingMap: View {
    @Environment(LocationManager.self) private var locationManager: LocationManager

    @State private var trackingVehicle: Vehicle? = nil

    @State private var isShowingVehicleList: Bool = false
    @State private var isShowingParkingHistory: Bool = false
    @State private var isShowingSettings: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Text("Mapp will be here")
            }
            .onAppear {
                locationManager.requestWhenInUseAuthorization()
                if trackingVehicle == nil {
                    isShowingVehicleList = true
                }
            }
            .toolbar {
                menu
                parkedAction
            }
            .sheet(isPresented: $isShowingVehicleList) {
                VehicleList(trackingVehicle: $trackingVehicle)
            }
            .sheet(isPresented: $isShowingParkingHistory) {
                //
            }
            .sheet(isPresented: $isShowingSettings) {
                //
            }
        }
    }
}

extension ParkingMap {
    @ToolbarContentBuilder
    var menu: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button("Vehicles", systemImage: "car.2") {
                    isShowingVehicleList = true
                }
                Button("Parking History", systemImage: "parkingsign.square") {
                    isShowingParkingHistory = true
                }
                Button("Settings", systemImage: "gearshape") {
                    isShowingSettings = true
                }
            } label: {
                Label("Menu", systemImage: "list.bullet")
            }
        }
    }
}

extension ParkingMap {
    @ToolbarContentBuilder
    var parkedAction: some ToolbarContent {
        if let trackingVehicle {
            ToolbarItem(placement: .bottomBar) {
                Button("SDF") {}
            }

            ToolbarSpacer(.flexible, placement: .bottomBar)

        } else {
            ToolbarItem(placement: .bottomBar) {
                Button("Track a vehicle") {
                    isShowingVehicleList = true
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .tint(.primary)
            }
        }
    }
}
