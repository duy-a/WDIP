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

    @State private var toastOpacity: Double = 0

    @State private var isPresentedInfo: Bool = false

    var pinColor: Color = .blue // Color of the teardrop shape
    var iconColor: Color = .white // Color of the SF Symbol inside
    var pinSize: CGSize = .init(width: 40, height: 60) // Size of the entire pin base

    // MARK: refactorin

    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var locationManager = LocationManager.shared

    @Query(sort: \Car.name)
    private var cars: [Car]

    @State private var userPosition: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)

    @State private var isShowingCarList: Bool = false
    @State private var selectedCar: Car = .init()

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
                        Label("Car Icon", systemImage: selectedCar.icon)
                            .labelStyle(.iconOnly)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(10)
                            .background(PickerColors(rawValue: selectedCar.color)?.uiColor ?? .red)
                            .clipShape(Circle())
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
            .navigationTitle(selectedCar.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        isShowingCarList = true
                    } label: {
                        Label("Car List", systemImage: "car.2")
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
            .sheet(isPresented: $isShowingCarList) {
                CarListView(selectedCarTracking: $selectedCar)
            }
            .onAppear {
                if cars.count <= 0 {
                    isShowingCarList = true
                } else {
                    selectedCar = cars.first!
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
        .modelContainer(for: Car.self, inMemory: true)
}
