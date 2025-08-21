//
//  ParkingMap.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 21/8/25.
//

import MapKit
import SwiftUI

struct ParkingMap: View {
    @StateObject private var locationManager = LocationManager.shared

    @State private var mapCameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var trackingVehicle: Vehicle = .init()

    @State private var isShowingVehicleList: Bool = false

    var body: some View {
        NavigationStack {
            Map(position: $mapCameraPosition) {
                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .overlay {
                VStack(spacing: 0) {
                    Button("Park Here", systemImage: trackingVehicle.icon) {}
                        .buttonStyle(.glassProminent)
                        .tint(trackingVehicle.uiColor)
                    Label("Parking Location Indicator", systemImage: "arrowtriangle.down.fill")
                        .foregroundStyle(trackingVehicle.uiColor)
                        .labelStyle(.iconOnly)
                        .imageScale(.large)
                }
                .offset(y: -27) // magic number, to make triangle point at the center
            }
            .onAppear {
                locationManager.requestWhenInUseAuthorization()
            }
            .toolbar {
                toolbarMenu()
            }
            .sheet(isPresented: $isShowingVehicleList) {
                VehicleList(trackingVehicle: $trackingVehicle)
            }
        }
    }
}

#Preview {
    ParkingMap()
}

extension ParkingMap {
    @ToolbarContentBuilder
    func toolbarMenu() -> some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Menu {
                Button("Vehicle List", systemImage: "car.2", action: showVehicleList)
                Button("Parking History", systemImage: "parkingsign.square", action: showParkingHistory)
            } label: {
                Label("Menu", systemImage: "list.bullet")
            }
        }
        
        ToolbarSpacer(.flexible, placement: .bottomBar)
        
        ToolbarItem(placement: .bottomBar) {
            Button("Parking Spot Info", systemImage: "info") {
                //
            }
        }
    }

    func showVehicleList() {
        isShowingVehicleList = true
    }

    func showParkingHistory() {
        //
    }
}
