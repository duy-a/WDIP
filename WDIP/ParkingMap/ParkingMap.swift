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

    @State private var mapCameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var currentVisibleRegion: MKCoordinateRegion?

    @State private var isShowingVehicleList: Bool = false
    @State private var isShowingParkingHistory: Bool = false
    @State private var isShowingSettings: Bool = false
    @State private var isShowingParkingMeter: Bool = false
    @State private var isShowingCurrentParkingSpotInfo: Bool = false

    @State private var timer: TimerManager = .init(endTime: .now)

    @State private var markerHeight: CGFloat = 0

    var body: some View {
        NavigationStack {
            Map(position: $mapCameraPosition) {
                UserAnnotation()

                if let trackingVehicle, let coordinates = trackingVehicle.currentParkingSpot?.coordinates {
                    Annotation(trackingVehicle.name, coordinate: coordinates, anchor: .bottom) {
                        ParkingMapMarker(actionName: "Unpark",
                                         icon: trackingVehicle.icon,
                                         color: trackingVehicle.uiColor,
                                         action: unpark)
                    }
                }
            }
            .onMapCameraChange {
                currentVisibleRegion = MKCoordinateRegion(
                    center: $0.camera.centerCoordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: $0.region.span.latitudeDelta,
                        longitudeDelta: $0.region.span.longitudeDelta
                    )
                )
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .overlay {
                if let trackingVehicle, !trackingVehicle.isParked {
                    ParkingMapMarker(actionName: "Park Here",
                                     icon: trackingVehicle.icon,
                                     color: trackingVehicle.uiColor,
                                     action: park)
                        .background(GeometryReader { geo in
                            Color.clear.onAppear {
                                markerHeight = geo.size.height
                            }
                        })
                        .offset(y: -(markerHeight / 2))
                }
            }
            .onAppear {
                locationManager.requestWhenInUseAuthorization()

                if trackingVehicle == nil {
                    isShowingVehicleList = true
                }
            }
            .onChange(of: trackingVehicle?.currentParkingSpot?.timerEndTime) {
                if let timerEndTime = trackingVehicle?.currentParkingSpot?.timerEndTime {
                    timer.endTime = timerEndTime
                    timer.start()
                } else {
                    timer.stop()
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
            .sheet(isPresented: $isShowingCurrentParkingSpotInfo) {
                if let parkingSpot = trackingVehicle?.currentParkingSpot {
                    ParkingSpotForm(parkingSpot: parkingSpot)
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
        if let trackingVehicle, trackingVehicle.isParked {
            ToolbarItem(placement: .bottomBar) {
                Button("Center on parked location", systemImage: trackingVehicle.icon, action: centerOnParkedSpot)
                    .tint(trackingVehicle.uiColor)
            }

            ToolbarSpacer(.flexible, placement: .bottomBar)

            ToolbarItem(placement: .bottomBar) {
                Button {
                    isShowingParkingMeter = true
                } label: {
                    if timer.remainingTime > 0 {
                        HStack {
                            Image(systemName: "powermeter")
                            Text(timer.formattedRemainingTime)
                        }
                    } else {
                        Label("Set meter timer & reminder", systemImage: "powermeter")
                    }
                }
            }

            ToolbarSpacer(.fixed, placement: .bottomBar)

            ToolbarItemGroup(placement: .bottomBar) {
                Button("Direction To Parking Spot", systemImage: "arrow.turn.left.up", action: getDirectionToParkedLocation)
                Button("Parking Spot Info", systemImage: "info") { isShowingCurrentParkingSpotInfo = true }
            }

        } else if trackingVehicle == nil {
            ToolbarItem(placement: .bottomBar) {
                Button("Track a vehicle") {
                    isShowingVehicleList = true
                }
                .buttonStyle(.glassProminent)
                .controlSize(.large)
                .tint(.primary)
            }
        } else {
            ToolbarItem(placement: .bottomBar) {
                Text("This is here to prevent shifting when the vehicle is parked")
                    .foregroundStyle(.clear)
            }
            .sharedBackgroundVisibility(.hidden)
        }
    }
}

extension ParkingMap {
    private func park() {
        let centerCoordinate: CLLocationCoordinate2D? = {
            if let region = currentVisibleRegion {
                return region.center
            } else if let userLocation = locationManager.currentLocation {
                return userLocation.coordinate
            } else {
                return nil
            }
        }()

        guard let trackingVehicle, let centerCoordinate else { return }

        let parkingSpot = ParkingSpot(coordinates: centerCoordinate)

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

    private func centerOnParkedSpot() {
        guard let trackingVehicle, let coordinates = trackingVehicle.currentParkingSpot?.coordinates else { return }

        mapCameraPosition = .camera(MapCamera(centerCoordinate: coordinates, distance: 3500))
    }

    private func getDirectionToParkedLocation() {
        if let parkingSpot = trackingVehicle?.currentParkingSpot {
            NavigationManager.openDirectionsInAppleMaps(coordinate: parkingSpot.coordinates,
                                                        name: parkingSpot.vehicle?.name ?? "Your parked vehicle")
        }
    }
}
