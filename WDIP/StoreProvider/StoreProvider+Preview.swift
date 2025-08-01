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
        
        sampleParkingSpot1.parkingEndTime = Calendar.current.date(byAdding: .minute, value: -30, to: .now)!
        sampleParkingSpot1.vehicle = sampleVehicle
        
        sampleParkingSpot2.parkingEndTime = Calendar.current.date(byAdding: .hour, value: -2, to: .now)!
        sampleParkingSpot2.vehicle = sampleVehicle
        
        sampleParkingSpot3.parkingEndTime = Calendar.current.date(byAdding: .day, value: -5, to: .now)!
        sampleParkingSpot3.vehicle = sampleVehicle
        
        modelContainer.mainContext.insert(sampleParkingSpot1)
        modelContainer.mainContext.insert(sampleParkingSpot2)
        modelContainer.mainContext.insert(sampleParkingSpot3)
        
        return storeProvider.modelContainer
    }()
}

extension StoreProvider {
    static let sampleVehicle = Vehicle(
        name: "Vehicle #\(Int.random(in: 1...10))",
        icon: PickerIcons.allCases.randomElement()!.rawValue,
        color: PickerColors.allCases.randomElement()!.rawValue
    )
    
    static let sampleParkingSpot1 = ParkingSpot(
        latitude: Constants.appleParkCoordinates.latitude,
        longitude: Constants.appleParkCoordinates.longitude,
    )
    
    static let sampleParkingSpot2 = ParkingSpot(
        latitude: Constants.appleVisitorCetnerCoordinates.latitude,
        longitude: Constants.appleVisitorCetnerCoordinates.longitude,
    )
    
    static let sampleParkingSpot3 = ParkingSpot(
        latitude: 0,
        longitude: 0,
    )
}
