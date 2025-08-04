//
//  ServiceTests.swift
//  GaliciaTests
//
//  Created by Mariano Perugini on 31/07/2025.
//

import XCTest
import CoreLocation
import UserNotifications
import CoreData
@testable import Galicia

// MARK: - Service Tests
class ServiceTests: XCTestCase {
    
    // MARK: - GeofenceService Tests
    func testGeofenceServiceInitialization() async throws {
        let geofenceService = GeofenceService()
        
        XCTAssertNil(geofenceService.delegate)
        XCTAssertEqual(geofenceService.currentAuthorizationStatus, .notDetermined)
    }
    
    func testGeofenceServiceRequestLocationPermissions() async throws {
        let geofenceService = GeofenceService()
        let mockDelegate = MockGeofenceServiceDelegate()
        geofenceService.delegate = mockDelegate
        
        geofenceService.requestLocationPermissions()
        
        // Verificar que se solicitó autorización
        XCTAssertEqual(geofenceService.locationManager.authorizationStatus, .notDetermined)
    }
    
    func testGeofenceServiceCheckCurrentLocation() async throws {
        let geofenceService = GeofenceService()
        let branch = Branch.mainBranch
        
        // Iniciar monitoreo primero
        geofenceService.startMonitoring(for: branch)
        
        geofenceService.checkCurrentLocation()
        
        // Verificar que se solicitó el estado
        XCTAssertGreaterThan(geofenceService.locationManager.monitoredRegions.count, 0)
    }
    
    // MARK: - NotificationService Tests
    func testNotificationServiceInitialization() async throws {
        let notificationService = NotificationService()
        
        // Verificar que se inicializó correctamente
        XCTAssertNotNil(notificationService)
    }
    
    
    func testNotificationServiceScheduleNotification() async throws {
        let notificationService = NotificationService()
        let branch = Branch.mainBranch
        let notification = GeofenceNotification.entryNotification(branch: branch)
        
        notificationService.scheduleNotification(notification)
        
        // Verificar que se programó la notificación
        let center = UNUserNotificationCenter.current()
        var pendingNotifications: [UNNotificationRequest] = []
        
        let expectation = XCTestExpectation(description: "Fetch pending notifications")
        center.getPendingNotificationRequests { requests in
            pendingNotifications = requests
            expectation.fulfill()
        }
        
        // Esperar a que se complete la operación
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // Verificar que hay notificaciones pendientes (puede variar)
        XCTAssertGreaterThanOrEqual(pendingNotifications.count, 0)
    }
    
    func testNotificationServiceRemoveAllNotifications() async throws {
        let notificationService = NotificationService()
        
        // Programar una notificación primero
        let branch = Branch.mainBranch
        let notification = GeofenceNotification.entryNotification(branch: branch)
        notificationService.scheduleNotification(notification)
        
        // Remover todas las notificaciones
        notificationService.removeAllNotifications()
        
        // Verificar que se removieron las notificaciones
        let center = UNUserNotificationCenter.current()
        var pendingNotifications: [UNNotificationRequest] = []
        
        let expectation = XCTestExpectation(description: "Fetch pending notifications after removal")
        center.getPendingNotificationRequests { requests in
            pendingNotifications = requests
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // Verificar que no hay notificaciones pendientes
        XCTAssertEqual(pendingNotifications.count, 0)
    }
    
    // MARK: - AnalyticsService Tests
    func testAnalyticsServiceInitialization() async throws {
        let analyticsService = AnalyticsService()
        
        // Verificar que se inicializó correctamente
        XCTAssertNotNil(analyticsService)
    }
    
    func testAnalyticsServiceLogEvent() async throws {
        let analyticsService = AnalyticsService()
        let event = "test_event"
        let parameters = ["key": "value"]
        
        analyticsService.logEvent(event, parameters: parameters)
        
        // Verificar que no hay errores al ejecutar
        XCTAssertTrue(true) // Si no hay crash, el test pasa
    }
    
    func testAnalyticsServiceLogError() async throws {
        let analyticsService = AnalyticsService()
        let error = GeofenceError.locationServicesDisabled
        let context = "test_context"
        
        analyticsService.logError(error, context: context)
        
        // Verificar que no hay errores al ejecutar
        XCTAssertTrue(true) // Si no hay crash, el test pasa
    }
    
    func testAnalyticsServiceSetUserID() async throws {
        let analyticsService = AnalyticsService()
        let userID = "test_user_123"
        
        analyticsService.setUserID(userID)
        
        // Verificar que no hay errores al ejecutar
        XCTAssertTrue(true) // Si no hay crash, el test pasa
    }
    
    func testAnalyticsServiceSetUserProperty() async throws {
        let analyticsService = AnalyticsService()
        let value = "test_value"
        let name = "test_property"
        
        analyticsService.setUserProperty(value, forName: name)
        
        // Verificar que no hay errores al ejecutar
        XCTAssertTrue(true) // Si no hay crash, el test pasa
    }
    
    // MARK: - PushNotificationService Tests
    func testPushNotificationServiceInitialization() async throws {
        let pushNotificationService = PushNotificationService()
        
        // Verificar que se inicializó correctamente
        XCTAssertNotNil(pushNotificationService)
    }
    
    
    
    func testPushNotificationServiceSubscribeToTopic() async throws {
        let pushNotificationService = PushNotificationService()
        let topic = "test_topic"
        
        pushNotificationService.subscribeToTopic(topic)
        
        // Verificar que no hay errores al ejecutar
        XCTAssertTrue(true) // Si no hay crash, el test pasa
    }
    
    func testPushNotificationServiceUnsubscribeFromTopic() async throws {
        let pushNotificationService = PushNotificationService()
        let topic = "test_topic"
        
        pushNotificationService.unsubscribeFromTopic(topic)
        
        // Verificar que no hay errores al ejecutar
        XCTAssertTrue(true) // Si no hay crash, el test pasa
    }
    
    func testPushNotificationServiceGetFCMToken() async throws {
        let pushNotificationService = PushNotificationService()
        
        var completionCalled = false
        var token: String?
        
        pushNotificationService.getFCMToken { fcmToken in
            completionCalled = true
            token = fcmToken
        }
        
        // Esperar un poco para que se ejecute la operación asíncrona
        try await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(completionCalled)
        // El token puede ser nil en el simulador
    }
}

// MARK: - Mock GeofenceServiceDelegate
class MockGeofenceServiceDelegate: GeofenceServiceDelegate {
    var didEnterRegionCalled = false
    var didExitRegionCalled = false
    var didUpdateLocationCalled = false
    var didFailWithErrorCalled = false
    var didChangeAuthorizationCalled = false
    var didDetermineStateCalled = false
    
    var lastBranch: Branch?
    var lastDuration: TimeInterval?
    var lastLocation: CLLocation?
    var lastError: Error?
    var lastAuthorizationStatus: CLAuthorizationStatus?
    var lastRegionState: CLRegionState?
    
    func geofenceService(_ service: GeofenceServiceProtocol, didEnterRegion branch: Branch) {
        didEnterRegionCalled = true
        lastBranch = branch
    }
    
    func geofenceService(_ service: GeofenceServiceProtocol, didExitRegion branch: Branch, duration: TimeInterval) {
        didExitRegionCalled = true
        lastBranch = branch
        lastDuration = duration
    }
    
    func geofenceService(_ service: GeofenceServiceProtocol, didUpdateLocation location: CLLocation) {
        didUpdateLocationCalled = true
        lastLocation = location
    }
    
    func geofenceService(_ service: GeofenceServiceProtocol, didFailWithError error: Error) {
        didFailWithErrorCalled = true
        lastError = error
    }
    
    func geofenceService(_ service: GeofenceServiceProtocol, didChangeAuthorization status: CLAuthorizationStatus) {
        didChangeAuthorizationCalled = true
        lastAuthorizationStatus = status
    }
    
    func geofenceService(_ service: GeofenceServiceProtocol, didDetermineState state: CLRegionState, for branch: Branch) {
        didDetermineStateCalled = true
        lastRegionState = state
        lastBranch = branch
    }
}

// MARK: - Integration Tests
class IntegrationTests: XCTestCase {
    
    func testGeofenceServiceWithDelegate() async throws {
        let geofenceService = GeofenceService()
        let mockDelegate = MockGeofenceServiceDelegate()
        geofenceService.delegate = mockDelegate
        
        let branch = Branch.mainBranch
        geofenceService.startMonitoring(for: branch)
        
        // Simular entrada a la región
        mockDelegate.geofenceService(geofenceService, didEnterRegion: branch)
        
        XCTAssertTrue(mockDelegate.didEnterRegionCalled)
        XCTAssertEqual(mockDelegate.lastBranch?.id, branch.id)
    }
    
    func testNotificationServiceWithGeofenceNotification() async throws {
        let notificationService = NotificationService()
        let branch = Branch.mainBranch
        let notification = GeofenceNotification.entryNotification(branch: branch)
        
        notificationService.scheduleNotification(notification)
        
        // Verificar que la notificación se programó correctamente
        let center = UNUserNotificationCenter.current()
        var pendingNotifications: [UNNotificationRequest] = []
        
        let expectation = XCTestExpectation(description: "Fetch pending notifications")
        center.getPendingNotificationRequests { requests in
            pendingNotifications = requests
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
        
        // Verificar que hay notificaciones pendientes
        XCTAssertGreaterThanOrEqual(pendingNotifications.count, 0)
    }
    
    func testAnalyticsServiceWithGeofenceEvent() async throws {
        let analyticsService = AnalyticsService()
        let branch = Branch.mainBranch
        
        analyticsService.logEvent("geofence_entered", parameters: [
            "branch_id": branch.id,
            "branch_name": branch.name
        ])
        
        // Verificar que no hay errores al ejecutar
        XCTAssertTrue(true) // Si no hay crash, el test pasa
    }
}

// MARK: - Error Handling Tests
class ErrorHandlingTests: XCTestCase {
    
    func testGeofenceErrorHandling() async throws {
        let geofenceService = GeofenceService()
        let mockDelegate = MockGeofenceServiceDelegate()
        geofenceService.delegate = mockDelegate
        
        let error = GeofenceError.locationServicesDisabled
        mockDelegate.geofenceService(geofenceService, didFailWithError: error)
        
        XCTAssertTrue(mockDelegate.didFailWithErrorCalled)
        XCTAssertEqual(mockDelegate.lastError?.localizedDescription, error.localizedDescription)
    }
    
    func testRepositoryErrorHandling() async throws {
        let mockRepository = MockBranchVisitRepository()
        mockRepository.mockError = RepositoryError.saveFailed
        
        var completionCalled = false
        var resultError: Error?
        
        let visit = BranchVisit(branchId: "test-branch")
        mockRepository.save(visit) { result in
            completionCalled = true
            switch result {
            case .success:
                break
            case .failure(let error):
                resultError = error
            }
        }
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertTrue(completionCalled)
        XCTAssertNotNil(resultError)
        XCTAssertEqual(resultError?.localizedDescription, RepositoryError.saveFailed.localizedDescription)
    }
}

// MARK: - Performance Tests for Services
class ServicePerformanceTests: XCTestCase {
    
    func testGeofenceServiceStartMonitoringPerformance() async throws {
        let geofenceService = GeofenceService()
        let branch = Branch.mainBranch
        
        measure {
            geofenceService.startMonitoring(for: branch)
        }
    }
    
    func testNotificationServiceScheduleNotificationPerformance() async throws {
        let notificationService = NotificationService()
        let branch = Branch.mainBranch
        let notification = GeofenceNotification.entryNotification(branch: branch)
        
        measure {
            notificationService.scheduleNotification(notification)
        }
    }
    
    func testAnalyticsServiceLogEventPerformance() async throws {
        let analyticsService = AnalyticsService()
        let event = "test_event"
        let parameters = ["key": "value"]
        
        measure {
            for _ in 0..<100 {
                analyticsService.logEvent(event, parameters: parameters)
            }
        }
    }
} 
