//
//  PushNotificationUseCase.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//

import Foundation

// MARK: - Push Notification Use Case Protocol
protocol PushNotificationUseCaseProtocol {
    func sendGeofenceEnteredNotification(branch: Branch)
    func sendGeofenceExitedNotification(branch: Branch, duration: TimeInterval)
    func sendServiceReminderNotification(branch: Branch, serviceType: ServiceType)
    func subscribeToBranchNotifications(branchId: String)
    func unsubscribeFromBranchNotifications(branchId: String)
    func getFCMToken(completion: @escaping (String?) -> Void)
}

// MARK: - Push Notification Use Case Implementation
final class PushNotificationUseCase: PushNotificationUseCaseProtocol {
    
    private let pushNotificationService: PushNotificationServiceProtocol
    private let analyticsUseCase: AnalyticsUseCaseProtocol
    
    init(pushNotificationService: PushNotificationServiceProtocol,
         analyticsUseCase: AnalyticsUseCaseProtocol) {
        self.pushNotificationService = pushNotificationService
        self.analyticsUseCase = analyticsUseCase
    }
    
    func sendGeofenceEnteredNotification(branch: Branch) {
        let title = "Bienvenido a Banco Galicia"
        let body = "Has ingresado a \(branch.name). ¿En qué podemos ayudarte?"
        
        let userInfo: [String: Any] = [
            "type": "geofence_entered",
            "branch_id": branch.id,
            "branch_name": branch.name,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        pushNotificationService.sendLocalNotification(
            title: title,
            body: body,
            userInfo: userInfo
        )
        
        // Analytics event
        analyticsUseCase.logEvent("push_notification_sent", parameters: [
            "notification_type": "geofence_entered",
            "branch_id": branch.id,
            "branch_name": branch.name
        ])
    }
    
    func sendGeofenceExitedNotification(branch: Branch, duration: TimeInterval) {
        let title = "Gracias por visitarnos"
        let body = "Estuviste \(formatDuration(duration)) en \(branch.name)"
        
        let userInfo: [String: Any] = [
            "type": "geofence_exited",
            "branch_id": branch.id,
            "branch_name": branch.name,
            "duration": duration,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        pushNotificationService.sendLocalNotification(
            title: title,
            body: body,
            userInfo: userInfo
        )
        
        // Analytics event
        analyticsUseCase.logEvent("push_notification_sent", parameters: [
            "notification_type": "geofence_exited",
            "branch_id": branch.id,
            "branch_name": branch.name,
            "duration": duration
        ])
    }
    
    func sendServiceReminderNotification(branch: Branch, serviceType: ServiceType) {
        let title = "Recordatorio de servicio"
        let body = "¿Necesitas ayuda con \(serviceType.rawValue.lowercased())?"
        
        let userInfo: [String: Any] = [
            "type": "service_reminder",
            "branch_id": branch.id,
            "branch_name": branch.name,
            "service_type": serviceType.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        pushNotificationService.sendLocalNotification(
            title: title,
            body: body,
            userInfo: userInfo
        )
        
        // Analytics event
        analyticsUseCase.logEvent("push_notification_sent", parameters: [
            "notification_type": "service_reminder",
            "branch_id": branch.id,
            "branch_name": branch.name,
            "service_type": serviceType.rawValue
        ])
    }
    
    func subscribeToBranchNotifications(branchId: String) {
        let topic = "branch_\(branchId)"
        pushNotificationService.subscribeToTopic(topic)
        
        // Analytics event
        analyticsUseCase.logEvent("push_topic_subscribed", parameters: [
            "topic": topic,
            "branch_id": branchId
        ])
    }
    
    func unsubscribeFromBranchNotifications(branchId: String) {
        let topic = "branch_\(branchId)"
        pushNotificationService.unsubscribeFromTopic(topic)
        
        // Analytics event
        analyticsUseCase.logEvent("push_topic_unsubscribed", parameters: [
            "topic": topic,
            "branch_id": branchId
        ])
    }
    
    func getFCMToken(completion: @escaping (String?) -> Void) {
        pushNotificationService.getFCMToken(completion: completion)
    }
    
    // MARK: - Private Helper Methods
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return "\(hours) horas, \(minutes) minutos"
        } else if minutes > 0 {
            return "\(minutes) minutos, \(seconds) segundos"
        } else {
            return "\(seconds) segundos"
        }
    }
} 