//
//  Car.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 23/7/25.
//

import Foundation
import MapKit
import SwiftData
import SwiftUI

@Model
final class Vehicle {
    var name: String = ""
    var icon: String = ""
    var color: String = ""
    var isParked: Bool = false

    @Relationship(deleteRule: .cascade, inverse: \ParkingSpot.vehicle)
    var parkingSpots: [ParkingSpot]?

    init(name: String = "", icon: String = "", color: String = "", isParked: Bool = false) {
        self.name = name
        self.icon = icon
        self.color = color
        self.isParked = isParked
    }

    var uiColor: Color {
        PickerColor.color(from: color)
    }

    var activeParkingSpot: ParkingSpot? {
        parkingSpots?.first { $0.isCurrentParkingSpot }
    }
}
