//
//  ViewModelTests.swift
//  GaliciaTests
//
//  Created by Mariano Perugini on 31/07/2025.
//

import XCTest
import CoreLocation
import Combine
import CoreData
@testable import Galicia

// MARK: - ViewModel Tests
class ViewModelTests: XCTestCase {
    
    func testBranchVisitViewModelInitialization() async throws {
        let mockGeofenceService = MockGeofenceService()
        let mockTrackVisitUseCase = MockTrackBranchVisitUseCase()
        let mockNotificationService = MockNotificationService()
        let mockAnalyticsUseCase = MockAnalyticsUseCase()
        
        let viewModel = BranchVisitViewModel(
            geofenceService: mockGeofenceService,
            trackVisitUseCase: mockTrackVisitUseCase,
            notificationService: mockNotificationService,
            analyticsUseCase: mockAnalyticsUseCase
        )
        
        XCTAssertFalse(viewModel.isInsideBranch)
        XCTAssertFalse(viewModel.showServiceSelection)
        XCTAssertTrue(viewModel.visitHistory.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.currentVisit)
    }
    
    func testBranchVisitViewModelSetupGeofence() async throws {
        let mockGeofenceService = MockGeofenceService()
        let mockTrackVisitUseCase = MockTrackBranchVisitUseCase()
        let mockNotificationService = MockNotificationService()
        let mockAnalyticsUseCase = MockAnalyticsUseCase()
        
        let viewModel = BranchVisitViewModel(
            geofenceService: mockGeofenceService,
            trackVisitUseCase: mockTrackVisitUseCase,
            notificationService: mockNotificationService,
            analyticsUseCase: mockAnalyticsUseCase
        )
        
        // Verificar que se configuró el delegate
        XCTAssertNotNil(mockGeofenceService.delegate)
        XCTAssertTrue(mockNotificationService.requestPermissionsCalled)
    }
    
    func testBranchVisitViewModelStartMonitoring() async throws {
        let mockGeofenceService = MockGeofenceService()
        let mockTrackVisitUseCase = MockTrackBranchVisitUseCase()
        let mockNotificationService = MockNotificationService()
        let mockAnalyticsUseCase = MockAnalyticsUseCase()
        
        let viewModel = BranchVisitViewModel(
            geofenceService: mockGeofenceService,
            trackVisitUseCase: mockTrackVisitUseCase,
            notificationService: mockNotificationService,
            analyticsUseCase: mockAnalyticsUseCase
        )
        
        viewModel.startMonitoring()
        
        XCTAssertTrue(mockGeofenceService.startMonitoringCalled)
    }
    
    func testBranchVisitViewModelSelectService() async throws {
        let mockGeofenceService = MockGeofenceService()
        let mockTrackVisitUseCase = MockTrackBranchVisitUseCase()
        let mockNotificationService = MockNotificationService()
        let mockAnalyticsUseCase = MockAnalyticsUseCase()
        
        let viewModel = BranchVisitViewModel(
            geofenceService: mockGeofenceService,
            trackVisitUseCase: mockTrackVisitUseCase,
            notificationService: mockNotificationService,
            analyticsUseCase: mockAnalyticsUseCase
        )
        
        viewModel.selectService(.teller)
        
        XCTAssertTrue(mockAnalyticsUseCase.logServiceSelectedCalled)
        XCTAssertTrue(mockTrackVisitUseCase.selectServiceCalled)
    }
}

// MARK: - Mock Use Cases para ViewModel Testing
class MockTrackBranchVisitUseCase: TrackBranchVisitUseCaseProtocol {
    var startVisitCalled = false
    var endVisitCalled = false
    var selectServiceCalled = false
    var getVisitHistoryCalled = false
    var mockError: Error?
    var mockVisit: BranchVisit?
    var mockVisits: [BranchVisit] = []
    
    func startVisit(at branch: Branch, completion: @escaping (Result<BranchVisit, Error>) -> Void) {
        startVisitCalled = true
        if let error = mockError {
            completion(.failure(error))
        } else {
            let visit = mockVisit ?? BranchVisit(branchId: branch.id)
            completion(.success(visit))
        }
    }
    
    func endVisit(completion: @escaping (Result<BranchVisit, Error>) -> Void) {
        endVisitCalled = true
        if let error = mockError {
            completion(.failure(error))
        } else {
            let visit = mockVisit ?? BranchVisit(branchId: "test-branch")
            completion(.success(visit))
        }
    }
    
    func selectService(_ serviceType: ServiceType, completion: @escaping (Result<Void, Error>) -> Void) {
        selectServiceCalled = true
        if let error = mockError {
            completion(.failure(error))
        } else {
            completion(.success(()))
        }
    }
    
    func getVisitHistory(completion: @escaping (Result<[BranchVisit], Error>) -> Void) {
        getVisitHistoryCalled = true
        if let error = mockError {
            completion(.failure(error))
        } else {
            completion(.success(mockVisits))
        }
    }
}

class MockAnalyticsUseCase: AnalyticsUseCaseProtocol {
    var logGeofenceEnteredCalled = false
    var logGeofenceExitedCalled = false
    var logServiceSelectedCalled = false
    var logLocationPermissionChangedCalled = false
    var logGeofenceStateDeterminedCalled = false
    var logErrorCalled = false
    var logEventCalled = false
    
    func logGeofenceEntered(branch: Branch) {
        logGeofenceEnteredCalled = true
    }
    
    func logGeofenceExited(branch: Branch, duration: TimeInterval) {
        logGeofenceExitedCalled = true
    }
    
    func logServiceSelected(serviceType: ServiceType) {
        logServiceSelectedCalled = true
    }
    
    func logLocationPermissionChanged(status: CLAuthorizationStatus) {
        logLocationPermissionChangedCalled = true
    }
    
    func logGeofenceStateDetermined(state: CLRegionState, for branch: Branch) {
        logGeofenceStateDeterminedCalled = true
    }
    
    func logError(_ error: Error, context: String) {
        logErrorCalled = true
    }
    
    func logEvent(_ event: String, parameters: [String: Any]?) {
        logEventCalled = true
    }
} 