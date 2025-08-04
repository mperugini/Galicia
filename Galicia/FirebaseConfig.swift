//
//  FirebaseConfig.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//

import Foundation
import Firebase
import FirebaseAnalytics

// MARK: - Firebase Configuration
struct FirebaseConfig {
    
    static func configure() {
        // Configure Firebase using GoogleService-Info.plist
        FirebaseApp.configure()
        
        // Enable Analytics debug mode in development
        #if DEBUG
        Analytics.setAnalyticsCollectionEnabled(true)
        #endif
        
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        
        // Set user properties for better analytics
        Analytics.setUserProperty("geofence_app", forName: "app_type")
        Analytics.setUserProperty("v1.0", forName: "app_version")
    }
    
    // MARK: - Analytics Events
    static func logGeofenceEvent(_ event: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(event, parameters: parameters)
    }
    
    static func logError(_ error: Error, context: String) {
         Crashlytics.crashlytics().record(error: error)
        
        Analytics.logEvent("app_error", parameters: [
            "error_description": error.localizedDescription,
            "error_domain": (error as NSError).domain,
            "error_code": (error as NSError).code,
            "context": context
        ])
    }
    
    static func setUserID(_ userID: String) {
        Analytics.setUserID(userID)
        Crashlytics.crashlytics().setUserID(userID)
    }
    
    static func setUserProperty(_ value: String?, forName name: String) {
        Analytics.setUserProperty(value, forName: name)
    }
}
