//
//  ParkingMapView.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 22/7/25.
//

import MapKit
import SwiftUI

struct ParkingMapView: View {
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var locationManager = LocationManager.shared

    @State private var userPosition: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)

    @State private var isParkingSpotSaved: Bool = false
    @Namespace private var namespace

    @State private var toastOpacity: Double = 0

    @State private var isPresentedInfo: Bool = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(position: $userPosition) {
                    UserAnnotation()

                    if isParkingSpotSaved {
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
                }
                .overlay {
                    if !isParkingSpotSaved {
                        Image(systemName: "mappin")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                            .offset(y: -15)
                    }
                }
                .onAppear {
                    locationManager.requestAuthorization()
                }

                VStack {
                    Text("Parking Spot Saved")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .glassEffect()
                        .padding(.horizontal)
                        .opacity(toastOpacity)

                    Spacer()

                    GlassEffectContainer(spacing: 10) {
                        HStack(spacing: 10) {
                            if !isParkingSpotSaved {
                                Button {
                                    withAnimation {
                                        isParkingSpotSaved.toggle()
                                    }

                                    Task {
                                        withAnimation(.bouncy) {
                                            toastOpacity = 1.0
                                        }

                                        try? await Task.sleep(for: .seconds(1), tolerance: .milliseconds(50))

                                        withAnimation(.easeOut(duration: 2.0)) {
                                            toastOpacity = 0.0
                                        }
                                    }
                                } label: {
                                    Label("Park Here", systemImage: "car")
                                        .font(.title2)
                                        .frame(maxWidth: .infinity)
                                        .glassEffectID("parked-directions", in: namespace)
                                }
                                .buttonStyle(.glassProminent)
                                .controlSize(.extraLarge)
                            }

                            if isParkingSpotSaved {
                                Button {
                                    withAnimation {
                                        isParkingSpotSaved.toggle()
                                    }
                                } label: {
                                    Label("Get Directions", systemImage: "arrow.turn.left.up")
                                        .font(.title2)
                                        .frame(maxWidth: .infinity)
                                        .glassEffectID("parked-directions", in: namespace)
                                }
                                .buttonStyle(.glassProminent)
                                .controlSize(.extraLarge)

                                Button {
                                    isPresentedInfo = true
                                } label: {
                                    Label("Parking Spot Details", systemImage: "info")
                                        .font(.title2)
                                        .labelStyle(.iconOnly)
                                        .glassEffectID("info", in: namespace)
                                }
                                .buttonStyle(.glass)
                                .controlSize(.extraLarge)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .sheet(isPresented: $isPresentedInfo) {
                NavigationStack {
                    Text("Addtional Parking spot goes here")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button {
                                    dismiss()
                                } label: {
                                    Label("Close info", systemImage: "xmark")
                                }
                            }
                        }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Label("Back", systemImage: "chevron.left")
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
}
