//
//  ParkingMap.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 13/9/25.
//

import MapKit
import SwiftData
import SwiftUI

struct ParkingMap: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LocationManager.self) private var locationManager: LocationManager

    @State private var trackingVehicle: Vehicle? = nil

    @State private var isShowingVehicleList: Bool = false
    @State private var isShowingParkingHistory: Bool = false
    @State private var isShowingSettings: Bool = false

    @State private var isShowingParkingMeter: Bool = false

    let appleParkCoordinates: CLLocationCoordinate2D = .init(latitude: 37.33478414571969, longitude: -122.00894818929088)

    var body: some View {
        NavigationStack {
            ZStack {
                if let trackingVehicle {
                    VStack {
                        if trackingVehicle.isParked {
                            Button("unpark", action: unpark)
                        } else {
                            Button("park", action: park)
                        }
                    }
                }
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
                ParkingSpotList(trackingVehicle: trackingVehicle)
            }
            .sheet(isPresented: $isShowingSettings) {
                Settings()
            }
            .sheet(isPresented: $isShowingParkingMeter) {
                if let parkingSpot = trackingVehicle?.currentParkingSpot {
                    ParkingSpotMeter(parkingSpot: parkingSpot)
                }
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
                Button("Center on parked location", systemImage: trackingVehicle.icon, action: {})
                    .tint(trackingVehicle.uiColor)
            }

            ToolbarSpacer(.flexible, placement: .bottomBar)

            ToolbarItem(placement: .bottomBar) {
                Button {
                    isShowingParkingMeter = true
                } label: {
                    Label("Set meter timer & reminder", systemImage: "powermeter")
                }
            }

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

extension ParkingMap {
    private func park() {
        guard let trackingVehicle else { return }

        let parkingSpot = ParkingSpot(coordinates: appleParkCoordinates)

        trackingVehicle.parkingSpots?.append(parkingSpot)
        trackingVehicle.isParked = true

        modelContext.insert(parkingSpot)

        Task.detached {
            parkingSpot.address = await LocationManager.getAddressBy(coordinates: parkingSpot.coordinates)
        }
    }

    private func unpark() {
        guard let trackingVehicle,
              trackingVehicle.isParked,
              let parkingSpot = trackingVehicle.currentParkingSpot
        else {
            return
        }

        trackingVehicle.isParked = false
        parkingSpot.parkingEndTime = .now.roundedDownToMinute
    }
}
