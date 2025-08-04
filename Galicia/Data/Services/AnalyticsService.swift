//
//  AnalyticsService.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//

import Foundation
import FirebaseAnalytics
import FirebaseCrashlytics

final class AnalyticsService: AnalyticsServiceProtocol {
    
    // MARK: - AnalyticsServiceProtocol
    func logEvent(_ event: String, parameters: [String: Any]?) {
        Analytics.logEvent(event, parameters: parameters)
    }
    
    func logError(_ error: Error, context: String) {
     
        Crashlytics.crashlytics().record(error: error)
        
        Analytics.logEvent("app_error", parameters: [
            "error_description": error.localizedDescription,
            "error_domain": (error as NSError).domain,
            "error_code": (error as NSError).code,
            "context": context
        ])
    }
    
    func setUserID(_ userID: String) {
        Analytics.setUserID(userID)
        Crashlytics.crashlytics().setUserID(userID)
    }
    
    func setUserProperty(_ value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
}

// MARK: - Analytics Event Names
struct AnalyticsEvents {
    static let geofenceEntered = "geofence_entered"
    static let geofenceExited = "geofence_exited"
    static let serviceSelected = "service_selected"
    static let locationPermissionChanged = "location_permission_changed"
    static let geofenceStateDetermined = "geofence_state_determined"
    static let geofenceError = "geofence_error"
    static let appError = "app_error"
} 
