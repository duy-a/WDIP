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
    
    init(name: String, icon: String, color: IconColor) {
        self.name = name
        self.icon = icon
        self.color = color.toString
    }
}

extension Car {
    enum IconColor: CaseIterable, Identifiable {
        case red
        case orange
        case yellow
        case green
        case blue
        case indigo
        case purple
        
        var id: String { self.toString }
        
        var toString: String {
            switch self {
            case .red:
                return "red"
            case .orange:
                return "orange"
            case .yellow:
                return "yellow"
            case .green:
                return "green"
            case .blue:
                return "blue"
            case .indigo:
                return "indigo"
            case .purple:
                return "purple"
            }
        }
        
        var uiColor: Color {
            switch self {
            case .red:
                return .red
            case .orange:
                return .orange
            case .yellow:
                return .yellow
            case .green:
                return .green
            case .blue:
                return .blue
            case .indigo:
                return .indigo
            case .purple:
                return .purple
            }
        }
    }
}
