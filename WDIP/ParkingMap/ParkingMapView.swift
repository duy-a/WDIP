//
//  ParkingMapView.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 22/7/25.
//

import MapKit
import SwiftUI

struct ParkingMapView: View {
    @ObservedObject private var locationManager = LocationManager.shared

    @State private var userPosition: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $userPosition) {
                UserAnnotation()
                
                Annotation("Apple Visitor Center", coordinate: Constants.appleVisitorCetnerCoordinates, anchor: .center) {
                    Image(systemName: "car.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                        .padding(8)
                        .background(.indigo.gradient, in: .circle)
                        .glassEffect()
                }
            }
            .overlay {
                Image(systemName: "mappin")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                    .offset(y: -15)
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
            .padding(.horizontal)
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
}
