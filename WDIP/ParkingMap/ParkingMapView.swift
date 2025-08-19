//
//  ParkingMapView.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 22/7/25.
//

import MapKit
import SwiftData
import SwiftUI

struct ParkingMapView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @ObservedObject private var locationManager = LocationManager.shared

    @Query(sort: \Vehicle.name)
    private var vehicles: [Vehicle]

    @Namespace private var namespace

    @State private var selectedVehicle: Vehicle = .init()

    @State private var mapCenterPosition: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @State private var mapCenterCoordintates: CLLocationCoordinate2D? = nil

    @State private var isShowingVehicleList: Bool = false
    @State private var isShowingParkingSpotInfo: Bool = false
    @State private var isShowingParkingSpotsHistory: Bool = false

    var currentParkingSpotCoordinates: CLLocationCoordinate2D? {
        guard let currentParkingSpot = selectedVehicle.currentParkingSpot else { return nil }

        return CLLocationCoordinate2D(
            latitude: currentParkingSpot.latitude,
            longitude: currentParkingSpot.longitude)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(position: $mapCenterPosition) {
                    UserAnnotation()

                    if selectedVehicle.isParked {
                        Marker(selectedVehicle.name, systemImage: selectedVehicle.icon, coordinate: currentParkingSpotCoordinates!)
                            .tint(PickerColors(rawValue: selectedVehicle.color)?.uiColor ?? .red)
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                }
                .overlay {
                    if !selectedVehicle.isParked {
                        ParkingSpotLabel(
                            icon: PickerIcons(rawValue: selectedVehicle.icon) ?? .car,
                            color: PickerColors(rawValue: selectedVehicle.color) ?? .red)
                    }
                }
                .onMapCameraChange {
                    mapCenterCoordintates = $0.camera.centerCoordinate
                }
                .onAppear {
                    locationManager.requestAuthorization()
                }

                actionButtons
            }
            .navigationTitle(selectedVehicle.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        isShowingVehicleList = true
                    } label: {
                        Label("Vehicle List", systemImage: "car.2")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingParkingSpotsHistory = true
                    } label: {
                        Label("Parking Spots History", systemImage: "parkingsign")
                    }
                }
            }
            .sheet(isPresented: $isShowingParkingSpotInfo) {
                ParkingSpotInfoView(parkingSpot: selectedVehicle.currentParkingSpot!, mapCameraPosition: $mapCenterPosition)
            }
            .sheet(isPresented: $isShowingVehicleList) {
                VehicleListView(selectedVehicleTracking: $selectedVehicle)
            }
            .sheet(isPresented: $isShowingParkingSpotsHistory) {
                ParkingSpotListView(mapCameraPosition: $mapCenterPosition)
            }
            .onAppear {
                if vehicles.count <= 0 {
                    isShowingVehicleList = true
                } else {
                    selectedVehicle = vehicles.first!
                }
            }
        }
    }

    func parkVehicleAtParkingSpot() {
        guard let mapCenterCoordintates else { return }

        selectedVehicle.isParked = true

        let newParkingSpot = ParkingSpot()
        newParkingSpot.latitude = mapCenterCoordintates.latitude
        newParkingSpot.longitude = mapCenterCoordintates.longitude
        newParkingSpot.vehicle = selectedVehicle

        modelContext.insert(newParkingSpot)
    }

    func centerOnParkedSpot() {
        guard let currentParkingSpotCoordinates else { return }
        withAnimation {
            mapCenterPosition = .camera(MapCamera(centerCoordinate: currentParkingSpotCoordinates, distance: 5000))
        }
    }

    func getDirectionsInMaps() {
        Task {
            guard let parkingSpot = selectedVehicle.currentParkingSpot else { return }
            guard let mkAddress = await parkingSpot.getMKAdress() else { return }
            let location = CLLocation(latitude: parkingSpot.latitude, longitude: parkingSpot.longitude)

            let destinationMapItem = MKMapItem(location: location, address: mkAddress)
            destinationMapItem.name = selectedVehicle.name

            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]

            destinationMapItem.openInMaps(launchOptions: launchOptions)
        }
    }

    func removeVehicleFromParkingSpot() {
        selectedVehicle.currentParkingSpot?.parkingEndTime = .now
        selectedVehicle.isParked = false
    }
}

#Preview {
    ParkingMapView()
        .modelContainer(StoreProvider.previewModelContainer)
}

extension ParkingMapView {
    var actionButtons: some View {
        GlassEffectContainer(spacing: 30) {
            HStack(alignment: .bottom, spacing: 30) {
                if selectedVehicle.isParked {
                    VStack(spacing: 30) {
                        Button {
                            centerOnParkedSpot()
                        } label: {
                            Label("Parked Location", systemImage: selectedVehicle.icon)
                                .font(.title2)
                                .labelStyle(.iconOnly)
                        }
                        .buttonStyle(.glass)
                        .controlSize(.extraLarge)
                        .buttonBorderShape(.circle)
                        .glassEffectID("directions", in: namespace)

                        Button {
                            getDirectionsInMaps()
                        } label: {
                            Label("Get directions", systemImage: "arrow.turn.left.up")
                                .font(.title2)
                                .labelStyle(.iconOnly)
                        }
                        .buttonStyle(.glass)
                        .controlSize(.extraLarge)
                        .buttonBorderShape(.circle)
                        .glassEffectID("parkedLocation", in: namespace)
                    }
                }

                Button {
                    withAnimation {
                        selectedVehicle.isParked ? removeVehicleFromParkingSpot() : parkVehicleAtParkingSpot()
                    }
                } label: {
                    Text(selectedVehicle.isParked ? "Got it" : "Park Here")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.extraLarge)
                .glassEffectID("park", in: namespace)
                .tint(PickerColors(rawValue: selectedVehicle.color)?.uiColor ?? .primary)

                if selectedVehicle.isParked {
                    Button {
                        isShowingParkingSpotInfo = true
                    } label: {
                        Label("Parking Spot Details", systemImage: "info")
                            .font(.title2)
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.glass)
                    .controlSize(.extraLarge)
                    .buttonBorderShape(.circle)
                    .glassEffectID("info", in: namespace)
                }
            }
        }
        .padding()
    }
}
