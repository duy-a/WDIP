//
//  StoreProvider+Schema.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 29/7/25.
//

import Foundation
import SwiftData

extension StoreProvider {
    static let schema = Schema([
        Car.self,
        ParkingSpot.self
    ])
}
