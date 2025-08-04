//
//  NotificationService.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//

import UserNotifications
import UIKit

final class NotificationService: NSObject, NotificationServiceProtocol {
    
    // MARK: - Properties
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Initialization
    override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    // MARK: - NotificationServiceProtocol
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) { granted, error in
            DispatchQueue.main.async {
                completion(granted && error == nil)
            }
        }
    }
    
    func scheduleNotification(_ notification: GeofenceNotification) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = .default
        content.userInfo = notification.userInfo
        
        // Add action category for entry notifications
        if notification.userInfo["type"] as? String == "entry" {
            content.categoryIdentifier = "BRANCH_ENTRY"
            setupNotificationCategories()
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Notification error: \(error.localizedDescription)")
            }
        }
    }
    
    func removeAllNotifications() {
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    // MARK: - Private Methods
    private func setupNotificationCategories() {
        let selectServiceAction = UNNotificationAction(
            identifier: "SELECT_SERVICE",
            title: "Seleccionar servicio",
            options: [.foreground]
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Cerrar",
            options: [.destructive]
        )
        
        let category = UNNotificationCategory(
            identifier: "BRANCH_ENTRY",
            actions: [selectServiceAction, dismissAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        notificationCenter.setNotificationCategories([category])
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification actions
        switch response.actionIdentifier {
        case "SELECT_SERVICE":
            // Post notification to open service selection
            NotificationCenter.default.post(
                name: .openServiceSelection,
                object: nil,
                userInfo: response.notification.request.content.userInfo
            )
        default:
            break
        }
        
        completionHandler()
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let openServiceSelection = Notification.Name("openServiceSelection")
}
