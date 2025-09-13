//
//  ParkingSpot.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 13/9/25.
//

import Foundation
import MapKit
import SwiftData

@Model
final class ParkingSpot {
    var id: String = UUID().uuidString
    var latitude: Double = 0.0
    var longtitude: Double = 0.0
    var parkStartTime: Date = Date.now
    var parkEndTime: Date = Date.now
    var isActive: Bool = false
    var timerEndTime: Date?
    var reminderEndTime: Date?
    
    var vehicle: Vehicle?

    init(coordinates: CLLocationCoordinate2D) {
        self.latitude = coordinates.latitude
        self.longtitude = coordinates.longitude
    }
}
