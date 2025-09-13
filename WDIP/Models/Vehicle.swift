//
//  Vehicle.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 13/9/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Vehicle {
    var id: String = UUID().uuidString
    var name: String = ""
    var icon: String = ""
    var color: String = ""
    var isParked: Bool = false

    @Relationship(deleteRule: .cascade, inverse: \ParkingSpot.vehicle)
    var parkingSpots: [ParkingSpot]? = []

    init() {}
}

extension Vehicle {
    var uiColor: Color {
        PickerColor.color(from: color)
    }

    var currentParkingSpot: ParkingSpot? {
        parkingSpots?.first { $0.parkEndTime == nil }
    }
}
