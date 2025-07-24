//
//  ParkingSpot.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 23/7/25.
//

import Foundation
import SwiftData

@Model
final class ParkingSpot {
    var latitude: Double
    var longitude: Double
    var parkingDate: Date
    var notes: String
    var photo: Data?
    
    var car: Car?
    
    init(latitude: Double, longitude: Double, parkingDate: Date = .now, notes: String = "", photo: Data? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.parkingDate = parkingDate
        self.notes = notes
        self.photo = photo
    }
}
