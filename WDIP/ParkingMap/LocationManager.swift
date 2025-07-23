//
//  LocationManager.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 22/7/25.
//

import Combine
import CoreLocation
import Foundation

final class LocationManager: NSObject, ObservableObject {
    @Published var userLocation: CLLocation? = nil
        
    static let shared = LocationManager()
    
    private var manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        } else {
            print("Location access not authorized to start updating.")
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            print("Not Determined")
        case .restricted:
            print("Restricted")
        case .denied:
            print("Denied")
        case .authorizedAlways:
            print("Always")
        case .authorizedWhenInUse:
            print("When in use")
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
    }
}
