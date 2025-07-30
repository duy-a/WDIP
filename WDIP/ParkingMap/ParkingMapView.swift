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
    @State private var isParkingSpotSaved: Bool = false
    @Namespace private var namespace

    // MARK: refactorin

    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var locationManager = LocationManager.shared

    @Query(sort: \Vehicle.name)
    private var vehicles: [Vehicle]

    @State private var mapCenterPosition: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
    @State private var mapCenterCoordintates: CLLocationCoordinate2D? = nil

    @State private var old: String = ""
    @State private var new: String = ""

    @State private var isShowingVehicleList: Bool = false
    @State private var isShowingParkingSpotInfo: Bool = false
    @State private var selectedVehicle: Vehicle = .init()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(position: $mapCenterPosition) {
                    UserAnnotation()

                    if isParkingSpotSaved {
                        Annotation("Parking Spot", coordinate: mapCenterCoordintates!, anchor: .center) {
                            ParkingSpotLabel(
                                icon: PickerIcons(rawValue: selectedVehicle.icon) ?? .car,
                                color: PickerColors(rawValue: selectedVehicle.color) ?? .red)
                        }
                    }
                }
                .overlay {
                    if !isParkingSpotSaved {
                        ParkingSpotLabel(
                            icon: PickerIcons(rawValue: selectedVehicle.icon) ?? .car,
                            color: PickerColors(rawValue: selectedVehicle.color) ?? .red)
                    }
                }
                .onMapCameraChange {
                    if !isParkingSpotSaved {
                        mapCenterCoordintates = $0.camera.centerCoordinate
                    }
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
            }
            .sheet(isPresented: $isShowingParkingSpotInfo) {
                ParkingSpotInfoView()
            }
            .sheet(isPresented: $isShowingVehicleList) {
                VehicleListView(selectedVehicleTracking: $selectedVehicle)
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

    func getUserCoordinates() async -> CLLocationCoordinate2D? {
        let updates = CLLocationUpdate.liveUpdates()

        do {
            let update = try await updates.first { $0.location?.coordinate != nil }
            return update?.location?.coordinate
        } catch {
            return nil
        }
    }
}

#Preview {
    ParkingMapView()
        .modelContainer(StoreProvider.previewModelContainer)
}

extension ParkingMapView {
    var actionButtons: some View {
        GlassEffectContainer(spacing: 30) {
            HStack(spacing: 30) {
                Button {
                    withAnimation {
                        isParkingSpotSaved.toggle()
                    }
                } label: {
                    Label("Park Here", systemImage: selectedVehicle.icon)
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.extraLarge)
                .glassEffectID("park", in: namespace)

                if isParkingSpotSaved {
                    Button {
                        isShowingParkingSpotInfo = true
                    } label: {
                        Label("Parking Spot Details", systemImage: "info")
                            .font(.title2)
                            .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.glass)
                    .controlSize(.extraLarge)
                    .glassEffectID("info", in: namespace)
                }
            }
        }
        .padding()
    }
}
