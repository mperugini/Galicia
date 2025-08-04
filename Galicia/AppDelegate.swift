//
//  AppDelegate.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//

import UIKit
import CoreData
import Firebase
import FirebaseMessaging
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Configure Firebase
        FirebaseConfig.configure()
        
        // Setup push notification service
        let pushService = DependencyContainer.shared.pushNotificationService
        pushService.requestPermissions { granted in
            if granted {
                print("[PUSH] Push notifications enabled")
                // Register for remote notifications
                application.registerForRemoteNotifications()
                // Note: Topic subscription will be done after APNs token is received
            } else {
                print("[PUSH] Push notifications denied")
            }
        }
        
        // Setup notification service
        _ = DependencyContainer.shared.notificationService
        
        // Handle background location updates
        if launchOptions?[.location] != nil {
            DependencyContainer.shared.geofenceService.startMonitoring(for: Branch.mainBranch)
        }
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreDataManager.shared.saveContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.shared.saveContext()
    }
    
    // MARK: - Push Notification Methods
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("[PUSH] Device token received")
        Messaging.messaging().apnsToken = deviceToken
        
        // Now that we have the APNs token, we can subscribe to topics
        let pushService = DependencyContainer.shared.pushNotificationService
        pushService.subscribeToTopic("geofence_notifications")
        
        // Get FCM token after APNs token is set
        pushService.getFCMToken { token in
            if let token = token {
                print("[PUSH] FCM Token received: \(token)")
            } else {
                print("[PUSH] Failed to get FCM token")
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("[PUSH] Failed to register for remote notifications: \(error.localizedDescription)")
        print("[PUSH] This is normal in development without APNs certificate")
        print("[PUSH] Local notifications will still work")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("[PUSH] Remote notification received: \(userInfo)")
        
        // Handle the notification
        if let notificationType = userInfo["type"] as? String {
            switch notificationType {
            case "geofence_entered":
                print("[PUSH] Geofence entered via push")
            case "geofence_exited":
                print("[PUSH] Geofence exited via push")
            default:
                print("[PUSH] Unknown notification type: \(notificationType)")
            }
        }
        
        completionHandler(.newData)
    }
}
