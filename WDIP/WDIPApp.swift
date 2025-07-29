//
//  WDIPApp.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 21/7/25.
//

import SwiftData
import SwiftUI

@main
struct WDIPApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(StoreProvider.shared.modelContainer)
    }
}
