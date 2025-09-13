//
//  StoreProvider+Schema.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 13/9/25.
//

import Foundation
import SwiftData

extension StoreProvider {
    static let schema = Schema([
        Vehicle.self,
        ParkingSpot.self
    ])
}
