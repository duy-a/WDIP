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
    var parkStartTime: Date = Date.now.roundedDownToMinute
    var parkEndTime: Date?
    var address: String = ""
    var timerEndTime: Date?
    var reminderEndTime: Date?
    var createdAt: Date = Date.now
    var notes: String = ""

    var vehicle: Vehicle?

    init(coordinates: CLLocationCoordinate2D) {
        self.latitude = coordinates.latitude
        self.longtitude = coordinates.longitude
    }
}
