//
//  PersistentStoreManager.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 29/7/25.
//

import Foundation
import SwiftData

final class StoreProvider {
    static let shared: StoreProvider = .init()
    
    var modelContainer: ModelContainer
    
    init(inMemory: Bool = false) {
        let modelConfiguration = ModelConfiguration(schema: StoreProvider.schema, isStoredInMemoryOnly: inMemory)

        do {
            modelContainer = try ModelContainer(for: StoreProvider.schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
