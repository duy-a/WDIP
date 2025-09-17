//
//  NavigationManager.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 17/9/25.
//

import Foundation
import MapKit

class NavigationManager {
    static func openDirectionsInAppleMaps(coordinate: CLLocationCoordinate2D, name: String = "") {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        let mapItem: MKMapItem = .init(location: location, address: nil)
        mapItem.name = name

        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]

        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    static func openDirectionsInGoogleMaps() {
        //
    }
}
