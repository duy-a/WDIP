//
//  ParkingMapView.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 22/7/25.
//

import MapKit
import SwiftUI

// On itial load a pin will be at the user location
// user can drag the map to change the pin location
// Big button to press save the parking location called "Pakred Here"

struct ParkingMapView: View {
    @ObservedObject private var locationManager = LocationManager.shared

    @State private var userPosition: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)

    @State private var test: MapCameraPosition = .region(
        .init(
            center: .init(latitude: 37.3346, longitude: -122.0090),
            latitudinalMeters: 1300,
            longitudinalMeters: 1300
        )
    )

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $userPosition) {
                UserAnnotation()
            }
            .overlay {
                Image(systemName: "mappin")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                    .offset(y: -15)
            }
            .mapControls {
                MapUserLocationButton()
            }
            .onAppear {
                locationManager.requestAuthorization()
            }

            HStack {
                Button {
                    //
                } label: {
                    Label("Park Here", systemImage: "car")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
                .controlSize(.extraLarge)
            }
            .padding()
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

    func setUserPosition() {
        Task {
            guard let userCoordinates = getUserCoordinates() else { return }
        }
    }
}

#Preview {
    ParkingMapView()
}
