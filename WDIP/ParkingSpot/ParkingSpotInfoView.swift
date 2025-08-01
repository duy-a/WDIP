//
//  ParkingSpotInfoView.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 29/7/25.
//

import MapKit
import SwiftData
import SwiftUI

struct ParkingSpotInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var parkingSpot: ParkingSpot

    @State private var notes: String = ""
    @State private var photo: Data? = nil

    @State private var position: MapCameraPosition = .camera(.init(
        centerCoordinate: Constants.appleParkCoordinates,
        distance: 2000
    ))

    var pinParkingSpotCoordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: parkingSpot.latitude, longitude: parkingSpot.longitude)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Map(position: $position) {
                        Marker("Parking Spot", coordinate: pinParkingSpotCoordinates)
                            .tint(.red)
                    }
                    .disabled(true)
                    .mapControlVisibility(.hidden)
                    .frame(height: 225)

                    Text(parkingSpot.address)
                }
                .listRowSeparator(.hidden)

                Section("Parking time - \(parkingSpot.parkingDuration)") {
                    Label {
                        Text(parkingSpot.parkingStartTime, format: .dateTime)
                    } icon: {
                        Image(systemName: "clock")
                    }
                    Label {
                        Text(parkingSpot.parkingEndTime, format: .dateTime)
                    } icon: {
                        Image(systemName: "clock.badge")
                    }
                }

                Section("Notes") {
                    TextField("Notes", text: $parkingSpot.notes, axis: .vertical)
                }

                if !parkingSpot.isCurrentParkingSpot {
                    Section {
                        Button {
                            delete()
                        } label: {
                            Label("Delete", systemImage: "trash")
                                .fontWeight(.semibold)
                                .labelStyle(.titleOnly)
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Parking Spot Info")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                position = .camera(.init(centerCoordinate: pinParkingSpotCoordinates, distance: 2000))
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close information", systemImage: "xmark")
                    }
                }
            }
        }
    }

    func delete() {
        modelContext.delete(parkingSpot)
        dismiss()
    }
}

#Preview {
    ParkingSpotInfoView(parkingSpot: StoreProvider.sampleParkingSpot1)
}
