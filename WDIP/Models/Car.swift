//
//  Car.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 23/7/25.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Car {
    var name: String
    var icon: String
    var color: String

    @Relationship(deleteRule: .cascade, inverse: \ParkingSpot.car)
    var parkingSpots: [ParkingSpot]?

    init(name: String = "", icon: String = "", color: String = "") {
        self.name = name
        self.icon = icon
        self.color = color
    }
}
