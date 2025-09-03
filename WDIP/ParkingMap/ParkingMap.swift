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
    @Environment(\.modelContext) private var modelContext

    @State private var locationManager = LocationManager.shared

    @Query(sort: \Vehicle.name) private var vehicles: [Vehicle]

    @State private var mapCameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var mapCenterCoordinates: CLLocationCoordinate2D? = nil

    @State private var trackingVehicle: Vehicle = .init()
    @State private var selectedParkingSpot: ParkingSpot? = nil

    @State private var isShowingVehicleList: Bool = false
    @State private var isShowingParkingSpotHistoryList: Bool = false
    @State private var isShowingSettings: Bool = false

    var currentParkingSpotCoordinates: CLLocationCoordinate2D? {
        trackingVehicle.activeParkingSpot?.coordinates
    }

    var body: some View {
        NavigationStack {
            Map(position: $mapCameraPosition) {
                UserAnnotation()

                if let currentParkingSpotCoordinates, trackingVehicle.isParked {
                    Annotation(trackingVehicle.name, coordinate: currentParkingSpotCoordinates, anchor: .bottom) {
                        ParkingMapMarker(actionName: "Unpark", icon: trackingVehicle.icon, color: trackingVehicle.uiColor, action: unpark)
                    }
                }
            }
            .onMapCameraChange {
                mapCenterCoordinates = $0.camera.centerCoordinate
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .overlay {
                ParkingMapMarker(actionName: "Park Here", icon: trackingVehicle.icon, color: trackingVehicle.uiColor, action: parkHere)
                    .alignmentGuide(VerticalAlignment.center) { d in d[.bottom] }
                    .opacity(trackingVehicle.isParked ? 0 : 1)
                    .disabled(trackingVehicle.isParked)
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
            .sheet(isPresented: $isShowingParkingSpotHistoryList) {
                ParkingSpotList(trackingVehicle: $trackingVehicle)
            }
            .sheet(isPresented: $isShowingSettings, content: {
                Settings()
            })
            .sheet(item: $selectedParkingSpot) { parkingSpot in
                ParkingSpotForm(parkingSpot: parkingSpot)
            }
            .onChange(of: vehicles) { oldVehicles, newVehicles in
                if oldVehicles.isEmpty && !newVehicles.isEmpty || !newVehicles.contains(trackingVehicle) {
                    trackFirstVehicle(vehicles: newVehicles)
                }
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
            Button("Park Here", systemImage: trackingVehicle.icon, action: parkHere)
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
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Button("Vehicles", systemImage: "car.2", action: showVehicleList)
                Button("Parking History", systemImage: "parkingsign.square", action: showParkingHistory)
                Button("Settings", systemImage: "gearshape", action: showSettings )
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
        if let activeParkingSpot = trackingVehicle.activeParkingSpot, trackingVehicle.isParked {
            ToolbarItem(placement: .bottomBar) {
                Button("Center on the Parking Spot", systemImage: trackingVehicle.icon, action: centerOnParkedSpot)
            }

            ToolbarSpacer(.fixed, placement: .bottomBar)

            ToolbarItemGroup(placement: .bottomBar) {
                Button("Direction To Parking Spot", systemImage: "arrow.turn.left.up", action: activeParkingSpot.getDirectionsInMaps)
                Button("Parking Spot Info", systemImage: "info", action: showCurrentParkingSpotInfo)
            }
        }
    }
}

private extension ParkingMap {
    func showVehicleList() {
        isShowingVehicleList = true
    }

    func showParkingHistory() {
        isShowingParkingSpotHistoryList = true
    }
    
    func showSettings() {
        isShowingSettings = true
    }

    func showCurrentParkingSpotInfo() {
        selectedParkingSpot = trackingVehicle.activeParkingSpot
    }

    func onStart() {
        locationManager.requestWhenInUseAuthorization()
        trackFirstVehicle(vehicles: vehicles)
    }

    func trackFirstVehicle(vehicles: [Vehicle]) {
        guard let vehicle = vehicles.first else { return showVehicleList() }

        trackingVehicle = vehicle
    }

    func parkHere() {
        guard let mapCenterCoordinates else { return }

        let parkingSpot = ParkingSpot(coordinates: mapCenterCoordinates)
        parkingSpot.vehicle = trackingVehicle

        trackingVehicle.isParked = true

        modelContext.insert(parkingSpot)
    }

    func unpark() {
        trackingVehicle.activeParkingSpot?.parkingEndTime = .now
        trackingVehicle.isParked = false
    }

    func centerOnParkedSpot() {
        guard let currentParkingSpotCoordinates else { return }

        withAnimation {
            mapCameraPosition = .camera(MapCamera(centerCoordinate: currentParkingSpotCoordinates, distance: 3500))
        }
    }
}
