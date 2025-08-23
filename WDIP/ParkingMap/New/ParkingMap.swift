//
//  ParkingMap.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 21/8/25.
//

import MapKit
import SwiftData
import SwiftUI

struct ParkingMap: View {
    @State private var locationManager = LocationManager.shared

    @Query(sort: \Vehicle.name) private var vehicles: [Vehicle]

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
                parkingPin
            }
            .onAppear {
                onStart()
            }
            .toolbar {
                menu
                parkedActions
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

// MARK: Parking Spot Selection Indicator

private extension ParkingMap {
    var parkingPin: some View {
        VStack(spacing: 0) {
            Button("Park Here", systemImage: trackingVehicle.icon) {
                //
            }
            .buttonStyle(.glassProminent)
            .tint(trackingVehicle.uiColor)

            Label("Parking Location Indicator", systemImage: "arrowtriangle.down.fill")
                .foregroundStyle(trackingVehicle.uiColor)
                .labelStyle(.iconOnly)
                .imageScale(.large)
        }
        .alignmentGuide(VerticalAlignment.center) { d in d[.bottom] }
    }
}

// MARK: Toolbar menu

private extension ParkingMap {
    @ToolbarContentBuilder
    var menu: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Menu {
                Button("Vehicles", systemImage: "car.2") {
                    showVehicleList()
                }
                Button("Parking History", systemImage: "parkingsign.square", action: showParkingHistory)
            } label: {
                Label("Menu", systemImage: "list.bullet")
            }
        }

        ToolbarSpacer(.flexible, placement: .bottomBar)
    }
}

// MARK: Toolbar main action buttons when vehicle is parked

private extension ParkingMap {
    @ToolbarContentBuilder
    var parkedActions: some ToolbarContent {
        ToolbarItem(placement: .bottomBar) {
            Button("Center on the Parking Spot", systemImage: trackingVehicle.icon) {
                //
            }
        }

        ToolbarSpacer(.fixed, placement: .bottomBar)

        ToolbarItemGroup(placement: .bottomBar) {
            Button("Direction To Parking Spot", systemImage: "arrow.turn.left.up") {
                //
            }

            Button("Parking Spot Info", systemImage: "info") {
                //
            }
        }
    }
}

private extension ParkingMap {
    func showVehicleList() {
        isShowingVehicleList = true
    }

    func showParkingHistory() {
        //
    }

    func onStart() {
        locationManager.requestWhenInUseAuthorization()

        if let vehicle = vehicles.first {
            trackingVehicle = vehicle
        } else {
            showVehicleList()
        }
    }
}
