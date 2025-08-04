//
//  RepositoryProtocols.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//

// MARK: - Domain Protocols

import Foundation
import CoreLocation

// MARK: - Repository Protocols
protocol BranchVisitRepositoryProtocol {
    func save(_ visit: BranchVisit, completion: @escaping (Result<BranchVisit, Error>) -> Void)
    func update(_ visit: BranchVisit, completion: @escaping (Result<BranchVisit, Error>) -> Void)
    func fetchAll(completion: @escaping (Result<[BranchVisit], Error>) -> Void)
    func fetchActiveVisit(completion: @escaping (Result<BranchVisit?, Error>) -> Void)
    func deleteAll(completion: @escaping (Result<Void, Error>) -> Void)
}

// MARK: - Service Protocols
protocol GeofenceServiceProtocol: AnyObject {
    var delegate: GeofenceServiceDelegate? { get set }
    func startMonitoring(for branch: Branch)
    func stopMonitoring()
    func checkCurrentLocation()
    func requestLocationPermissions()
    func forceCheckCurrentState()
    var currentAuthorizationStatus: CLAuthorizationStatus { get }
}

protocol NotificationServiceProtocol {
    func requestPermissions(completion: @escaping (Bool) -> Void)
    func scheduleNotification(_ notification: GeofenceNotification)
    func removeAllNotifications()
}

protocol AnalyticsServiceProtocol {
    func logEvent(_ event: String, parameters: [String: Any]?)
    func logError(_ error: Error, context: String)
    func setUserID(_ userID: String)
    func setUserProperty(_ value: String?, forName name: String)
}

// MARK: - Delegate Protocols
protocol GeofenceServiceDelegate: AnyObject {
    func geofenceService(_ service: GeofenceServiceProtocol, didEnterRegion branch: Branch)
    func geofenceService(_ service: GeofenceServiceProtocol, didExitRegion branch: Branch, duration: TimeInterval)
    func geofenceService(_ service: GeofenceServiceProtocol, didUpdateLocation location: CLLocation)
    func geofenceService(_ service: GeofenceServiceProtocol, didFailWithError error: Error)
    func geofenceService(_ service: GeofenceServiceProtocol, didChangeAuthorization status: CLAuthorizationStatus)
    func geofenceService(_ service: GeofenceServiceProtocol, didDetermineState state: CLRegionState, for branch: Branch)
}

// MARK: - Use Case Protocols
protocol TrackBranchVisitUseCaseProtocol {
    func startVisit(at branch: Branch, completion: @escaping (Result<BranchVisit, Error>) -> Void)
    func endVisit(completion: @escaping (Result<BranchVisit, Error>) -> Void)
    func selectService(_ serviceType: ServiceType, completion: @escaping (Result<Void, Error>) -> Void)
    func getVisitHistory(completion: @escaping (Result<[BranchVisit], Error>) -> Void)
}

// MARK: - Error Types
enum GeofenceError: LocalizedError {
    case locationServicesDisabled
    case insufficientPermissions
    case monitoringNotAvailable
    case regionMonitoringFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .locationServicesDisabled:
            return "Los servicios de ubicación están deshabilitados"
        case .insufficientPermissions:
            return "Se requieren permisos de ubicación 'Siempre'"
        case .monitoringNotAvailable:
            return "El monitoreo de región no está disponible"
        case .regionMonitoringFailed(let reason):
            return "Error en el monitoreo: \(reason)"
        }
    }
}

enum RepositoryError: LocalizedError {
    case saveFailed
    case fetchFailed
    case updateFailed
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Error al guardar los datos"
        case .fetchFailed:
            return "Error al obtener los datos"
        case .updateFailed:
            return "Error al actualizar los datos"
        case .notFound:
            return "Datos no encontrados"
        }
    }
}
