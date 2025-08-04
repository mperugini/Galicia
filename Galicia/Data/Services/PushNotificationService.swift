//
//  PushNotificationService.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//

import Foundation
import UIKit
import UserNotifications
import FirebaseMessaging

// MARK: - Push Notification Service Protocol
protocol PushNotificationServiceProtocol {
    func requestPermissions(completion: @escaping (Bool) -> Void)
    func registerForRemoteNotifications()
    func subscribeToTopic(_ topic: String)
    func unsubscribeFromTopic(_ topic: String)
    func getFCMToken(completion: @escaping (String?) -> Void)
    func sendLocalNotification(title: String, body: String, userInfo: [String: Any]?)
}

// MARK: - Push Notification Service Implementation
final class PushNotificationService: NSObject, PushNotificationServiceProtocol {
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        setupMessaging()
    }
    
    // MARK: - Setup
    private func setupMessaging() {
        Messaging.messaging().delegate = self
        notificationCenter.delegate = self
    }
    
    // MARK: - PushNotificationServiceProtocol
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.registerForRemoteNotifications()
                }
                completion(granted && error == nil)
            }
        }
    }
    
    func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func subscribeToTopic(_ topic: String) {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            if let error = error {
                print("[PUSH] Error subscribing to topic \(topic): \(error.localizedDescription)")
            } else {
                print("[PUSH] Subscribed to topic: \(topic)")
            }
        }
    }
    
    func unsubscribeFromTopic(_ topic: String) {
        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            if let error = error {
                print("[PUSH] Error unsubscribing from topic \(topic): \(error.localizedDescription)")
            } else {
                print("[PUSH] Unsubscribed from topic: \(topic)")
            }
        }
    }
    
    func getFCMToken(completion: @escaping (String?) -> Void) {
        Messaging.messaging().token { token, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[PUSH] Error getting FCM token: \(error.localizedDescription)")
                    completion(nil)
                } else {
                    print("[PUSH] FCM Token: \(token ?? "nil")")
                    completion(token)
                }
            }
        }
    }
    
    func sendLocalNotification(title: String, body: String, userInfo: [String: Any]? = nil) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = userInfo ?? [:]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("[PUSH] Error sending local notification: \(error.localizedDescription)")
            } else {
                print("[PUSH] Local notification sent: \(title)")
            }
        }
    }
}

// MARK: - MessagingDelegate
extension PushNotificationService: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("[PUSH] FCM registration token updated: \(fcmToken ?? "nil")")
        
        // Aquí puedes enviar el token a tu servidor
        if let token = fcmToken {
            // TODO: Send token to server
            print("[PUSH] Token ready to send to server: \(token)")
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension PushNotificationService: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        print("[PUSH] Notification received: \(userInfo)")
        
        // Handle notification tap
        handleNotificationTap(userInfo: userInfo as? [String: Any] ?? [:])
        
        completionHandler()
    }
    
    private func handleNotificationTap(userInfo: [String: Any]) {
        // Handle different types of notifications
        if let notificationType = userInfo["type"] as? String {
            switch notificationType {
            case "geofence_entered":
                print("[PUSH] Geofence entered notification tapped")
                NotificationCenter.default.post(name: .openServiceSelection, object: nil)
                
            case "geofence_exited":
                print("[PUSH] Geofence exited notification tapped")
                
            case "service_reminder":
                print("[PUSH] Service reminder notification tapped")
                
            default:
                print("[PUSH] Unknown notification type: \(notificationType)")
            }
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let fcmTokenReceived = Notification.Name("fcmTokenReceived")
    static let pushNotificationReceived = Notification.Name("pushNotificationReceived")
} 
