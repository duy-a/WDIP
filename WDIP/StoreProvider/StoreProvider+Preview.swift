//
//  StoreProvider+Preview.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 29/7/25.
//

import Foundation
import SwiftData

extension StoreProvider {
    static var previewModelContainer: ModelContainer = {
        let storeProvider = StoreProvider(inMemory: true)
        
        let modelContainer = storeProvider.modelContainer
        
        modelContainer.mainContext.insert(sampleVehicle)
        
        return storeProvider.modelContainer
    }()
}

extension StoreProvider {
    static let sampleVehicle = Vehicle(
        name: "Vehicle #\(Int.random(in: 1...10))",
        icon: PickerIcons.allCases.randomElement()!.rawValue,
        color: PickerColors.allCases.randomElement()!.rawValue
    )
}
