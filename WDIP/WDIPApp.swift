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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State private var locationManager: LocationManager = .shared
    @State private var notificationManager: NotificationManager = .shared

    var body: some Scene {
        WindowGroup {
            ParkingMap()
        }
        .modelContainer(StoreProvider.shared.modelContainer)
        .environment(locationManager)
        .environment(notificationManager)
    }
}
