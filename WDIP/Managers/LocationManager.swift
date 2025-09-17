//
//  LocationManager.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 13/9/25.
//

import CoreLocation
import MapKit

@Observable
final class LocationManager: NSObject {
    private(set) var currentLocation: CLLocation?
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined

    static let shared = LocationManager()

    private let locationManager = CLLocationManager()

    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            manager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
}

extension LocationManager {
    static func getAddressBy(coordinates: CLLocationCoordinate2D) async -> String {
        return await getMKAddressBy(latitude: coordinates.latitude, longitude: coordinates.longitude)?.fullAddress ?? ""
    }

    static func getAddressBy(latitude: Double, longitude: Double) async -> String {
        return await getMKAddressBy(latitude: latitude, longitude: longitude)?.fullAddress ?? ""
    }

    static func getMKAddressBy(latitude: Double, longitude: Double) async -> MKAddress? {
        let location: CLLocation = .init(latitude: latitude, longitude: longitude)

        do {
            guard let mapItem = try await MKReverseGeocodingRequest(location: location)?.mapItems.first else { return nil }

            return mapItem.address
        } catch {
            return nil
        }
    }
}
