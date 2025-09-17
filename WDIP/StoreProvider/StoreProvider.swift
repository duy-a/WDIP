//
//  StoreProvider.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 13/9/25.
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
