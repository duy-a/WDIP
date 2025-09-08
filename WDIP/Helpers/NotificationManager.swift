//
//  NotificationManager.swift
//  WDIP
//
//  Created by Duy Anh Ngac on 8/9/25.
//

import UserNotifications

@Observable
final class NotificationManager {
    static let shared: NotificationManager = .init()

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()

        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge, .provisional])
        } catch {
            return false
        }
    }

    func checkPermissionStatus() async -> UNAuthorizationStatus {
        return await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }
}
