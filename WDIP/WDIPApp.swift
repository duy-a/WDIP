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
    @AppStorage("isViewedOnboarding") private var isViewedOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            if isViewedOnboarding {
                ParkingMap()
            } else {
                Onboarding()
            }
        }
        .modelContainer(StoreProvider.shared.modelContainer)
    }
}
