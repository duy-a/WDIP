//
//  StoreProvider+Preview.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 29/7/25.
//

import Foundation
import SwiftData
import CoreLocation

extension StoreProvider {
    static var previewModelContainer: ModelContainer = {
        let storeProvider = StoreProvider(inMemory: true)
        
        let modelContainer = storeProvider.modelContainer
        
        sampleParkingSpot.vehicle = sampleVehicle
        
        modelContainer.mainContext.insert(sampleParkingSpot)
        
        return storeProvider.modelContainer
    }()
}

extension StoreProvider {
    static let sampleVehicle = Vehicle(
        name: "Vehicle #\(Int.random(in: 1...10))",
        icon: PickerIcons.allCases.randomElement()!.rawValue,
        color: PickerColors.allCases.randomElement()!.rawValue
    )
    
    static let sampleParkingSpot = ParkingSpot(
        latitude: Constants.appleParkCoordinates.latitude,
        longitude: Constants.appleParkCoordinates.longitude
    )
}
