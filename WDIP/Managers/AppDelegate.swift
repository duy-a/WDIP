//
//  AppDelegate.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 18/9/25.
//
import CoreData
import Foundation
import SwiftData
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // Just let the merge machinery run, actual scheduling will happen in handleRemoteChange
        completionHandler(.newData)
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleRemoteChange()
        }
        return true
    }
}

extension AppDelegate {
    private func handleRemoteChange() {
        Task {
            do {
                let context = StoreProvider.shared.modelContainer.mainContext

                let spots = try context.fetch(FetchDescriptor<ParkingSpot>())
                // TODO: find a way to update only the changed objects

                for spot in spots {
                    print("🔄 Remote merge, updated reminderEndTime:", spot.reminderEndTime as Any)
                    spot.cancelNotificationReminder()
                    spot.scheduleNotificationReminder()
                }
            } catch {
                print("⚠️ Failed to process remote change:", error)
            }
        }
    }
}
