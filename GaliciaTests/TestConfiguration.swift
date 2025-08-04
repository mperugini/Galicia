//
//  TestConfiguration.swift
//  GaliciaTests
//
//  Created by Mariano Perugini on 31/07/2025.
//

import XCTest
import CoreLocation
import CoreData
@testable import Galicia

// MARK: - Test Configuration
struct TestConfiguration {
    
    // MARK: - Test Data
    static let testBranch = Branch(
        id: "test-branch",
        name: "Sucursal de Prueba",
        coordinate: CLLocationCoordinate2D(latitude: -35.6330328, longitude: -59.7783535),
        radius: 10.0
    )
    
    static let testVisit = BranchVisit(branchId: "test-branch")
    
    static let testLocation = CLLocation(
        latitude: -35.6330328,
        longitude: -59.7783535
    )
    
    // MARK: - Test Constants
    static let testTimeout: TimeInterval = 5.0
    static let testIterations = 1000
    
    // MARK: - Test Helpers
    static func createTestBranch(id: String = "test-branch") -> Branch {
        return Branch(
            id: id,
            name: "Sucursal de Prueba \(id)",
            coordinate: CLLocationCoordinate2D(latitude: -35.6330328, longitude: -59.7783535),
            radius: 10.0
        )
    }
    
    static func createTestVisit(branchId: String = "test-branch") -> BranchVisit {
        return BranchVisit(branchId: branchId)
    }
    
    static func createTestVisitWithService(branchId: String = "test-branch", serviceType: ServiceType = .teller) -> BranchVisit {
        var visit = BranchVisit(branchId: branchId)
        visit.serviceType = serviceType
        visit.exitTime = Date()
        return visit
    }
    
    static func createTestNotification(branch: Branch = testBranch) -> GeofenceNotification {
        return GeofenceNotification.entryNotification(branch: branch)
    }
    
    static func createTestError() -> GeofenceError {
        return GeofenceError.locationServicesDisabled
    }
    
    // MARK: - Async Test Helpers
    static func waitForAsyncOperation(timeout: TimeInterval = testTimeout) async throws {
        try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
    }
    
    static func waitForCompletion<T>(_ operation: @escaping (@escaping (T) -> Void) -> Void) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            operation { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    static func waitForResult<T>(_ operation: @escaping (@escaping (Result<T, Error>) -> Void) -> Void) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            operation { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Test Categories
enum TestCategory {
    case unit
    case integration
    case performance
    case ui
    case network
    case database
}

// MARK: - Test Tags
struct TestTags {
    static let unit = "unit"
    static let integration = "integration"
    static let performance = "performance"
    static let ui = "ui"
    static let network = "network"
    static let database = "database"
    static let geofencing = "geofencing"
    static let notifications = "notifications"
    static let analytics = "analytics"
    static let firebase = "firebase"
}

// MARK: - Test Assertions
struct TestAssertions {
    
    static func assertSuccess<T>(_ result: Result<T, Error>, file: StaticString = #file, line: UInt = #line) {
        switch result {
        case .success:
            break
        case .failure(let error):
            XCTFail("Expected success but got error: \(error.localizedDescription)", file: file, line: line)
        }
    }
    
    static func assertFailure<T>(_ result: Result<T, Error>, expectedError: Error? = nil, file: StaticString = #file, line: UInt = #line) {
        switch result {
        case .success(let value):
            XCTFail("Expected failure but got success: \(value)", file: file, line: line)
        case .failure(let error):
            if let expectedError = expectedError {
                XCTAssertEqual(error.localizedDescription, expectedError.localizedDescription, file: file, line: line)
            }
        }
    }
    
    static func assertNotNil<T>(_ value: T?, message: String = "Value should not be nil", file: StaticString = #file, line: UInt = #line) {
        XCTAssertNotNil(value, message, file: file, line: line)
    }
    
    static func assertNil<T>(_ value: T?, message: String = "Value should be nil", file: StaticString = #file, line: UInt = #line) {
        XCTAssertNil(value, message, file: file, line: line)
    }
    
    static func assertEqual<T: Equatable>(_ lhs: T, _ rhs: T, message: String = "Values should be equal", file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(lhs, rhs, message, file: file, line: line)
    }
    
    static func assertTrue(_ value: Bool, message: String = "Value should be true", file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(value, message, file: file, line: line)
    }
    
    static func assertFalse(_ value: Bool, message: String = "Value should be false", file: StaticString = #file, line: UInt = #line) {
        XCTAssertFalse(value, message, file: file, line: line)
    }
}

// MARK: - Performance Test Helpers
struct PerformanceTestHelpers {
    
    static func measurePerformance<T>(_ operation: () -> T, iterations: Int = TestConfiguration.testIterations) -> TimeInterval {
        let startTime = Date()
        
        for _ in 0..<iterations {
            _ = operation()
        }
        
        let endTime = Date()
        return endTime.timeIntervalSince(startTime)
    }
    
    static func assertPerformance<T>(_ operation: () -> T, maxDuration: TimeInterval, iterations: Int = TestConfiguration.testIterations, file: StaticString = #file, line: UInt = #line) {
        let duration = measurePerformance(operation, iterations: iterations)
        XCTAssertLessThan(duration, maxDuration, "Performance test failed: took \(duration)s, expected less than \(maxDuration)s", file: file, line: line)
    }
}

// MARK: - Mock Data Generators
struct MockDataGenerators {
    
    static func generateTestBranches(count: Int) -> [Branch] {
        return (0..<count).map { index in
            Branch(
                id: "branch-\(index)",
                name: "Sucursal de Prueba \(index)",
                coordinate: CLLocationCoordinate2D(
                    latitude: -35.6330328 + Double(index) * 0.001,
                    longitude: -59.7783535 + Double(index) * 0.001
                ),
                radius: 10.0
            )
        }
    }
    
    static func generateTestVisits(count: Int, branchId: String = "test-branch") -> [BranchVisit] {
        return (0..<count).map { index in
            var visit = BranchVisit(branchId: branchId)
            visit.serviceType = index % 2 == 0 ? .teller : .personalizedService
            visit.exitTime = Date().addingTimeInterval(Double(index) * 3600) // 1 hora por visita
            return visit
        }
    }
    
    static func generateTestLocations(count: Int) -> [CLLocation] {
        return (0..<count).map { index in
            CLLocation(
                latitude: -35.6330328 + Double(index) * 0.001,
                longitude: -59.7783535 + Double(index) * 0.001
            )
        }
    }
    
    static func generateTestErrors() -> [Error] {
        return [
            GeofenceError.locationServicesDisabled,
            GeofenceError.insufficientPermissions,
            GeofenceError.monitoringNotAvailable,
            GeofenceError.regionMonitoringFailed("Test error"),
            RepositoryError.saveFailed,
            RepositoryError.fetchFailed,
            RepositoryError.updateFailed,
            RepositoryError.notFound
        ]
    }
}

// MARK: - Test Environment Setup
struct TestEnvironment {
    
    static func setupTestEnvironment() {
        // Configurar el entorno de pruebas
        print("🧪 Setting up test environment...")
        
        // Limpiar datos de prueba si es necesario
        cleanupTestData()
        
        // Configurar mocks globales si es necesario
        setupGlobalMocks()
    }
    
    static func cleanupTestData() {
        // Limpiar datos de Core Data de prueba
        let coreDataManager = CoreDataManager.shared
        let context = coreDataManager.persistentContainer.viewContext
        
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BranchVisitEntity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("⚠️ Error cleaning test data: \(error)")
        }
    }
    
    static func setupGlobalMocks() {
        // Configurar mocks globales si es necesario
        print("🔧 Setting up global mocks...")
    }
    
    static func teardownTestEnvironment() {
        // Limpiar el entorno de pruebas
        print("🧹 Tearing down test environment...")
        
        cleanupTestData()
    }
}

// MARK: - Test Utilities
struct TestUtilities {
    
    static func isRunningInSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    static func isRunningInTests() -> Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
    
    static func getTestBundle() -> Bundle {
        return Bundle.main
    }
    
    static func getTestResourcePath(_ resourceName: String) -> String? {
        return getTestBundle().path(forResource: resourceName, ofType: nil)
    }
    
    static func loadTestData(_ fileName: String) -> Data? {
        guard let path = getTestResourcePath(fileName) else { return nil }
        return try? Data(contentsOf: URL(fileURLWithPath: path))
    }
}

// MARK: - Test Reporting
struct TestReporting {
    
    static func logTestStart(_ testName: String, category: TestCategory = .unit) {
        print("🚀 Starting test: \(testName) [\(category)]")
    }
    
    static func logTestSuccess(_ testName: String, duration: TimeInterval) {
        print("✅ Test passed: \(testName) (\(String(format: "%.3f", duration))s)")
    }
    
    static func logTestFailure(_ testName: String, error: Error) {
        print("❌ Test failed: \(testName) - \(error.localizedDescription)")
    }
    
    static func logPerformanceTest(_ testName: String, duration: TimeInterval, iterations: Int) {
        let averageDuration = duration / Double(iterations)
        print("⚡ Performance test: \(testName) - \(String(format: "%.6f", averageDuration))s per iteration (\(iterations) iterations)")
    }
} 