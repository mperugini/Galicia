//
//  GaliciaTests.swift
//  GaliciaTests
//
//  Created by Mariano Perugini on 31/07/2025.
//

import XCTest
import CoreLocation
import CoreData
@testable import Galicia

// MARK: - Test Suite Principal
class GaliciaTests: XCTestCase {
    
    // MARK: - Domain Models Tests
    func testBranchModel() async throws {
        let coordinate = CLLocationCoordinate2D(latitude: -35.6330328, longitude: -59.7783535)
        let branch = Branch(
            id: "test-branch",
            name: "Sucursal de Prueba",
            coordinate: coordinate,
            radius: 10.0
        )
        
        XCTAssertEqual(branch.id, "test-branch")
        XCTAssertEqual(branch.name, "Sucursal de Prueba")
        XCTAssertEqual(branch.coordinate.latitude, coordinate.latitude)
        XCTAssertEqual(branch.coordinate.longitude, coordinate.longitude)
        XCTAssertEqual(branch.radius, 10.0)
    }
    
    func testBranchVisitModel() async throws {
        let visit = BranchVisit(branchId: "test-branch")
        
        XCTAssertEqual(visit.branchId, "test-branch")
        XCTAssertNotNil(visit.entryTime)
        XCTAssertNil(visit.exitTime)
        XCTAssertNil(visit.serviceType)
        XCTAssertNil(visit.duration)
    }
    
    func testBranchVisitWithService() async throws {
        var visit = BranchVisit(branchId: "test-branch")
        visit.serviceType = .teller
        visit.exitTime = Date()
        
        XCTAssertEqual(visit.serviceType, .teller)
        XCTAssertNotNil(visit.exitTime)
        XCTAssertNotNil(visit.duration)
    }
    
    func testServiceTypeEnum() async throws {
        XCTAssertEqual(ServiceType.teller.rawValue, "Atención por caja")
        XCTAssertEqual(ServiceType.personalizedService.rawValue, "Atención personalizada")
        XCTAssertEqual(ServiceType.personalLoans.rawValue, "Créditos Personales")
        XCTAssertEqual(ServiceType.other.rawValue, "Otros trámites")
        
        XCTAssertEqual(ServiceType(rawValue: "Atención por caja"), .teller)
        XCTAssertEqual(ServiceType(rawValue: "Atención personalizada"), .personalizedService)
        XCTAssertEqual(ServiceType(rawValue: "Créditos Personales"), .personalLoans)
        XCTAssertEqual(ServiceType(rawValue: "Otros trámites"), .other)
        XCTAssertNil(ServiceType(rawValue: "invalid"))
    }
    
    // MARK: - GeofenceNotification Tests
    func testGeofenceNotificationEntry() async throws {
        let branch = Branch.mainBranch
        let notification = GeofenceNotification.entryNotification(branch: branch)
        
        XCTAssertEqual(notification.title, "Bienvenido a Banco Galicia")
        XCTAssertTrue(notification.body.contains(branch.name))
        XCTAssertEqual(notification.userInfo["branchId"] as? String, branch.id)
        XCTAssertEqual(notification.userInfo["type"] as? String, "entry")
    }
    
    func testGeofenceNotificationExit() async throws {
        let branch = Branch.mainBranch
        let duration = "30 minutos"
        let notification = GeofenceNotification.exitNotification(branch: branch, duration: duration)
        
        XCTAssertEqual(notification.title, "Gracias por visitarnos")
        XCTAssertTrue(notification.body.contains(duration))
        XCTAssertTrue(notification.body.contains(branch.name))
        XCTAssertEqual(notification.userInfo["branchId"] as? String, branch.id)
        XCTAssertEqual(notification.userInfo["type"] as? String, "exit")
    }
    
    // MARK: - Error Types Tests
    func testGeofenceErrorDescriptions() async throws {
        let locationDisabled = GeofenceError.locationServicesDisabled
        let insufficientPermissions = GeofenceError.insufficientPermissions
        let monitoringNotAvailable = GeofenceError.monitoringNotAvailable
        let regionMonitoringFailed = GeofenceError.regionMonitoringFailed("Test error")
        
        XCTAssertTrue(locationDisabled.errorDescription?.contains("servicios de ubicación") == true)
        XCTAssertTrue(insufficientPermissions.errorDescription?.contains("permisos de ubicación") == true)
        XCTAssertTrue(monitoringNotAvailable.errorDescription?.contains("monitoreo de región") == true)
        XCTAssertTrue(regionMonitoringFailed.errorDescription?.contains("Test error") == true)
    }
    
    func testRepositoryErrorDescriptions() async throws {
        let saveFailed = RepositoryError.saveFailed
        let fetchFailed = RepositoryError.fetchFailed
        let updateFailed = RepositoryError.updateFailed
        let notFound = RepositoryError.notFound
        
        XCTAssertTrue(saveFailed.errorDescription?.contains("guardar") == true)
        XCTAssertTrue(fetchFailed.errorDescription?.contains("obtener") == true)
        XCTAssertTrue(updateFailed.errorDescription?.contains("actualizar") == true)
        XCTAssertTrue(notFound.errorDescription?.contains("encontrado") == true)
    }
}

// MARK: - Mock Services para Testing
class MockGeofenceService: GeofenceServiceProtocol {
    var delegate: GeofenceServiceDelegate?
    var currentAuthorizationStatus: CLAuthorizationStatus = .authorizedAlways
    var mockLocation: CLLocation?
    var mockError: Error?
    var startMonitoringCalled = false
    var stopMonitoringCalled = false
    
    func startMonitoring(for branch: Branch) {
        startMonitoringCalled = true
        if let error = mockError {
            delegate?.geofenceService(self, didFailWithError: error)
        }
    }
    
    func stopMonitoring() {
        stopMonitoringCalled = true
    }
    
    func checkCurrentLocation() {
        if let location = mockLocation {
            delegate?.geofenceService(self, didUpdateLocation: location)
        }
    }
    
    func requestLocationPermissions() {
        delegate?.geofenceService(self, didChangeAuthorization: currentAuthorizationStatus)
    }
    
    func forceCheckCurrentState() {
        // Mock implementation
    }
}

class MockBranchVisitRepository: BranchVisitRepositoryProtocol {
    var mockVisits: [BranchVisit] = []
    var mockActiveVisit: BranchVisit?
    var saveCalled = false
    var updateCalled = false
    var fetchAllCalled = false
    var fetchActiveVisitCalled = false
    var deleteAllCalled = false
    var mockError: Error?
    
    func save(_ visit: BranchVisit, completion: @escaping (Result<BranchVisit, Error>) -> Void) {
        saveCalled = true
        if let error = mockError {
            completion(.failure(error))
        } else {
            mockVisits.append(visit)
            completion(.success(visit))
        }
    }
    
    func update(_ visit: BranchVisit, completion: @escaping (Result<BranchVisit, Error>) -> Void) {
        updateCalled = true
        if let error = mockError {
            completion(.failure(error))
        } else {
            if let index = mockVisits.firstIndex(where: { $0.id == visit.id }) {
                mockVisits[index] = visit
            }
            completion(.success(visit))
        }
    }
    
    func fetchAll(completion: @escaping (Result<[BranchVisit], Error>) -> Void) {
        fetchAllCalled = true
        if let error = mockError {
            completion(.failure(error))
        } else {
            completion(.success(mockVisits))
        }
    }
    
    func fetchActiveVisit(completion: @escaping (Result<BranchVisit?, Error>) -> Void) {
        fetchActiveVisitCalled = true
        if let error = mockError {
            completion(.failure(error))
        } else {
            completion(.success(mockActiveVisit))
        }
    }
    
    func deleteAll(completion: @escaping (Result<Void, Error>) -> Void) {
        deleteAllCalled = true
        if let error = mockError {
            completion(.failure(error))
        } else {
            mockVisits.removeAll()
            completion(.success(()))
        }
    }
}

class MockNotificationService: NotificationServiceProtocol {
    var requestPermissionsCalled = false
    var scheduleNotificationCalled = false
    var removeAllNotificationsCalled = false
    var mockPermissionsGranted = true
    var scheduledNotifications: [GeofenceNotification] = []
    
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        requestPermissionsCalled = true
        completion(mockPermissionsGranted)
    }
    
    func scheduleNotification(_ notification: GeofenceNotification) {
        scheduleNotificationCalled = true
        scheduledNotifications.append(notification)
    }
    
    func removeAllNotifications() {
        removeAllNotificationsCalled = true
        scheduledNotifications.removeAll()
    }
}

class MockAnalyticsService: AnalyticsServiceProtocol {
    var loggedEvents: [(event: String, parameters: [String: Any]?)] = []
    var loggedErrors: [(error: Error, context: String)] = []
    var setUserIDCalled = false
    var setUserPropertyCalled = false
    var mockUserID: String?
    var mockUserProperties: [String: String] = [:]
    
    func logEvent(_ event: String, parameters: [String: Any]?) {
        loggedEvents.append((event: event, parameters: parameters))
    }
    
    func logError(_ error: Error, context: String) {
        loggedErrors.append((error: error, context: context))
    }
    
    func setUserID(_ userID: String) {
        setUserIDCalled = true
        mockUserID = userID
    }
    
    func setUserProperty(_ value: String?, forName name: String) {
        setUserPropertyCalled = true
        mockUserProperties[name] = value
    }
}

// MARK: - Use Case Tests
class UseCaseTests: XCTestCase {
    
    func testTrackBranchVisitUseCaseStartVisit() async throws {
        let mockRepository = MockBranchVisitRepository()
        let mockNotificationService = MockNotificationService()
        let useCase = TrackBranchVisitUseCase(
            repository: mockRepository,
            notificationService: mockNotificationService
        )
        
        let branch = Branch.mainBranch
        var completionCalled = false
        var resultVisit: BranchVisit?
        var resultError: Error?
        
        useCase.startVisit(at: branch) { result in
            completionCalled = true
            switch result {
            case .success(let visit):
                resultVisit = visit
            case .failure(let error):
                resultError = error
            }
        }
        
        // Esperar un poco para que se ejecute la operación asíncrona
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 segundos
        
        XCTAssertTrue(completionCalled)
        XCTAssertTrue(mockRepository.saveCalled)
        XCTAssertTrue(mockNotificationService.scheduleNotificationCalled)
        XCTAssertNotNil(resultVisit)
        XCTAssertNil(resultError)
    }
    
    func testAnalyticsUseCaseLogGeofenceEntered() async throws {
        let mockAnalyticsService = MockAnalyticsService()
        let useCase = AnalyticsUseCase(analyticsService: mockAnalyticsService)
        
        let branch = Branch.mainBranch
        useCase.logGeofenceEntered(branch: branch)
        
        XCTAssertEqual(mockAnalyticsService.loggedEvents.count, 1)
        XCTAssertEqual(mockAnalyticsService.loggedEvents.first?.event, "geofence_entered")
        XCTAssertEqual(mockAnalyticsService.loggedEvents.first?.parameters?["branch_id"] as? String, branch.id)
        XCTAssertEqual(mockAnalyticsService.loggedEvents.first?.parameters?["branch_name"] as? String, branch.name)
    }
}

// MARK: - Performance Tests
class PerformanceTests: XCTestCase {
    
    func testBranchVisitCreationPerformance() async throws {
        let iterations = 1000
        
        measure {
            for _ in 0..<iterations {
                let _ = BranchVisit(branchId: "test-branch")
            }
        }
    }
    
    func testGeofenceNotificationCreationPerformance() async throws {
        let iterations = 1000
        let branch = Branch.mainBranch
        
        measure {
            for _ in 0..<iterations {
                let _ = GeofenceNotification.entryNotification(branch: branch)
            }
        }
    }
}
