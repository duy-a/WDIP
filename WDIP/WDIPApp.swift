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
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @AppStorage("isViewedOnboarding") private var isViewedOnboarding: Bool = false
    @State private var notificationManager: NotificationManager = .shared

    var body: some Scene {
        WindowGroup {
            if isViewedOnboarding {
                ParkingMap()
                    .onAppear {
                        StoreProvider.shared.migrate()
                    }
            } else {
                Onboarding()
            }
        }
        .modelContainer(StoreProvider.shared.modelContainer)
        .environment(notificationManager)
    }
}
