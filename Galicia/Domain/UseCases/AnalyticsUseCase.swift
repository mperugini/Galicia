//
//  AnalyticsUseCase.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//

import Foundation
import CoreLocation

// MARK: - Analytics Use Case Protocol
protocol AnalyticsUseCaseProtocol {
    func logGeofenceEntered(branch: Branch)
    func logGeofenceExited(branch: Branch, duration: TimeInterval)
    func logServiceSelected(serviceType: ServiceType)
    func logLocationPermissionChanged(status: CLAuthorizationStatus)
    func logGeofenceStateDetermined(state: CLRegionState, for branch: Branch)
    func logError(_ error: Error, context: String)
    func logEvent(_ event: String, parameters: [String: Any]?)
}

// MARK: - Analytics Use Case Implementation
final class AnalyticsUseCase: AnalyticsUseCaseProtocol {
    
    private let analyticsService: AnalyticsServiceProtocol
    
    init(analyticsService: AnalyticsServiceProtocol) {
        self.analyticsService = analyticsService
    }
    
    func logGeofenceEntered(branch: Branch) {
        analyticsService.logEvent(AnalyticsEvents.geofenceEntered, parameters: [
            "branch_id": branch.id,
            "branch_name": branch.name,
            "latitude": branch.coordinate.latitude,
            "longitude": branch.coordinate.longitude
        ])
    }
    
    func logGeofenceExited(branch: Branch, duration: TimeInterval) {
        analyticsService.logEvent(AnalyticsEvents.geofenceExited, parameters: [
            "branch_id": branch.id,
            "branch_name": branch.name,
            "duration_seconds": duration,
            "latitude": branch.coordinate.latitude,
            "longitude": branch.coordinate.longitude
        ])
    }
    
    func logServiceSelected(serviceType: ServiceType) {
        analyticsService.logEvent(AnalyticsEvents.serviceSelected, parameters: [
            "service_type": serviceType.rawValue,
            "service_icon": serviceType.icon
        ])
    }
    
    func logLocationPermissionChanged(status: CLAuthorizationStatus) {
        analyticsService.logEvent(AnalyticsEvents.locationPermissionChanged, parameters: [
            "authorization_status": status.rawValue,
            "status_description": statusDescription(for: status)
        ])
    }
    
    func logGeofenceStateDetermined(state: CLRegionState, for branch: Branch) {
        analyticsService.logEvent(AnalyticsEvents.geofenceStateDetermined, parameters: [
            "branch_id": branch.id,
            "branch_name": branch.name,
            "state": stateDescription(for: state),
            "latitude": branch.coordinate.latitude,
            "longitude": branch.coordinate.longitude
        ])
    }
    
    func logError(_ error: Error, context: String) {
        analyticsService.logError(error, context: context)
    }
    
    func logEvent(_ event: String, parameters: [String: Any]?) {
        analyticsService.logEvent(event, parameters: parameters)
    }
    
    // MARK: - Private Helper Methods
    private func statusDescription(for status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "not_determined"
        case .restricted: return "restricted"
        case .denied: return "denied"
        case .authorizedAlways: return "authorized_always"
        case .authorizedWhenInUse: return "authorized_when_in_use"
        @unknown default: return "unknown"
        }
    }
    
    private func stateDescription(for state: CLRegionState) -> String {
        switch state {
        case .inside: return "inside"
        case .outside: return "outside"
        case .unknown: return "unknown"
        @unknown default: return "unknown"
        }
    }
} 
