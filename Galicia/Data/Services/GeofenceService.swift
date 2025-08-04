//
//  GeofenceService.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//

import Foundation
import CoreLocation

final class GeofenceService: NSObject, GeofenceServiceProtocol {
    
    // MARK: - Properties
    weak var delegate: GeofenceServiceDelegate?
    let locationManager: CLLocationManager
    private var monitoredBranch: Branch?
    private let backgroundTaskIdentifier = "com.bancogalicia.geofence"
    private var lastReportedState: CLRegionState = .unknown
    
    // MARK: - Initialization
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Private Methods
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .otherNavigation
    }
    
    // MARK: - GeofenceServiceProtocol
    func startMonitoring(for branch: Branch) {
        print("[GEOFENCE] Iniciando monitoreo para sucursal: \(branch.name)")
        print("[GEOFENCE] Coordenadas: \(branch.coordinate.latitude), \(branch.coordinate.longitude)")
        print("[GEOFENCE] Radio: \(branch.radius) metros")
        
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            print("[GEOFENCE] Monitoreo de regiones no disponible")
            delegate?.geofenceService(self, didFailWithError: GeofenceError.monitoringNotAvailable)
            return
        }
        
        let region = createRegion(for: branch)
        monitoredBranch = branch
        lastReportedState = .unknown // Reset state
        
        print("[GEOFENCE] Limpiando regiones anteriores...")
        // Clear previous regions
        locationManager.monitoredRegions.forEach { locationManager.stopMonitoring(for: $0) }
        
        print("[GEOFENCE] Iniciando monitoreo de región: \(region.identifier)")
        // Start monitoring
        locationManager.startMonitoring(for: region)
        locationManager.startUpdatingLocation()
        
        print("[GEOFENCE] Solicitando estado inicial...")
        // Request initial state
        locationManager.requestState(for: region)
    }
    
    func stopMonitoring() {
        locationManager.monitoredRegions.forEach { locationManager.stopMonitoring(for: $0) }
        locationManager.stopUpdatingLocation()
        monitoredBranch = nil
    }
    
    func checkCurrentLocation() {
        guard let branch = monitoredBranch else { return }
        let region = createRegion(for: branch)
        locationManager.requestState(for: region)
    }
    
    func forceCheckCurrentState() {
        print("[GEOFENCE] Forzando verificación de estado actual")
        checkCurrentLocation()
    }
    
    func requestLocationPermissions() {
        let status = locationManager.authorizationStatus
        print("[GEOFENCE] Estado actual de permisos: \(status.rawValue)")
        
        switch status {
        case .notDetermined:
            print("[GEOFENCE] Permisos no determinados, solicitando autorización 'Siempre'")
            locationManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse:
            print("[GEOFENCE] Permisos solo 'Al usar', solicitando autorización 'Siempre'")
            locationManager.requestAlwaysAuthorization()
        case .denied, .restricted:
            print("[GEOFENCE] Permisos denegados o restringidos")
            delegate?.geofenceService(self, didFailWithError: GeofenceError.insufficientPermissions)
        case .authorizedAlways:
            print("[GEOFENCE] Permisos 'Siempre' concedidos")
            delegate?.geofenceService(self, didChangeAuthorization: status)
        @unknown default:
            print("[GEOFENCE] Estado de permisos desconocido")
            break
        }
    }
    
    // MARK: - Helper Methods
    private func createRegion(for branch: Branch) -> CLCircularRegion {
        let region = CLCircularRegion(
            center: branch.coordinate,
            radius: branch.radius,
            identifier: branch.id
        )
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }
}

// MARK: - CLLocationManagerDelegate
extension GeofenceService: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("[GEOFENCE] Cambio de autorización: \(manager.authorizationStatus.rawValue)")
        delegate?.geofenceService(self, didChangeAuthorization: manager.authorizationStatus)
        
        if manager.authorizationStatus == .authorizedAlways,
           let branch = monitoredBranch {
            print("[GEOFENCE] Permisos concedidos, iniciando monitoreo automático")
            startMonitoring(for: branch)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("[GEOFENCE] Ubicación actualizada: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        print("[GEOFENCE] Precisión: \(location.horizontalAccuracy) metros")
        
        // Calcular distancia si tenemos una sucursal monitoreada
        if let branch = monitoredBranch {
            let distance = location.distance(from: CLLocation(latitude: branch.coordinate.latitude, longitude: branch.coordinate.longitude))
            print("[GEOFENCE] Distancia a sucursal: \(distance) metros (radio: \(branch.radius)m)")
            
            let currentState: CLRegionState = distance <= branch.radius ? .inside : .outside
            
            if distance <= branch.radius {
                print("[GEOFENCE] DENTRO del geofence")
            } else {
                print("[GEOFENCE] FUERA del geofence")
            }
            
            // Solo notificar si el estado cambió
            if currentState != lastReportedState {
                print("[GEOFENCE] Cambio de estado detectado: \(lastReportedState.rawValue) -> \(currentState.rawValue)")
                lastReportedState = currentState
                delegate?.geofenceService(self, didDetermineState: currentState, for: branch)
            }
        }
        
        delegate?.geofenceService(self, didUpdateLocation: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("[GEOFENCE] Entrada detectada en región: \(region.identifier)")
        
        guard let branch = monitoredBranch,
              region.identifier == branch.id else { 
            print("[GEOFENCE] Región no coincide con sucursal monitoreada")
            return 
        }
        
        print("[GEOFENCE] Usuario entró a sucursal: \(branch.name)")
        print("[GEOFENCE] Coordenadas: \(branch.coordinate.latitude), \(branch.coordinate.longitude)")
        print("[GEOFENCE] Radio: \(branch.radius) metros")
        
        delegate?.geofenceService(self, didEnterRegion: branch)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("[GEOFENCE] Salida detectada en región: \(region.identifier)")
        
        guard let branch = monitoredBranch,
              region.identifier == branch.id else { 
            print("[GEOFENCE] Región no coincide con sucursal monitoreada")
            return 
        }
        
        print("[GEOFENCE] Usuario salió de sucursal: \(branch.name)")
        print("[GEOFENCE] Coordenadas: \(branch.coordinate.latitude), \(branch.coordinate.longitude)")
        
        // Calculate duration using timestamps or delegate to use case
        delegate?.geofenceService(self, didExitRegion: branch, duration: 0)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("[GEOFENCE] Estado determinado para región: \(region.identifier)")
        
        guard let branch = monitoredBranch,
              region.identifier == branch.id else { 
            print("[GEOFENCE] Región no coincide con sucursal monitoreada")
            return 
        }
        
        // Calcular distancia real si tenemos ubicación
        if let location = manager.location {
            let distance = location.distance(from: CLLocation(latitude: branch.coordinate.latitude, longitude: branch.coordinate.longitude))
            print("[GEOFENCE] Distancia real: \(distance) metros")
            print("[GEOFENCE] Radio del geofence: \(branch.radius) metros")
            print("[GEOFENCE] Diferencia: \(distance - branch.radius) metros")
        }
        
        switch state {
        case .inside:
            print("[GEOFENCE] Usuario está DENTRO de la sucursal: \(branch.name)")
            // Notificar al delegate sobre el estado actual
            delegate?.geofenceService(self, didDetermineState: .inside, for: branch)
        case .outside:
            print("[GEOFENCE] Usuario está FUERA de la sucursal: \(branch.name)")
            // Notificar al delegate sobre el estado actual
            delegate?.geofenceService(self, didDetermineState: .outside, for: branch)
        case .unknown:
            print("[GEOFENCE] Estado DESCONOCIDO para sucursal: \(branch.name)")
            // State unknown, could retry
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("[GEOFENCE] Error en monitoreo de región: \(error.localizedDescription)")
        let geofenceError = GeofenceError.regionMonitoringFailed(error.localizedDescription)
        delegate?.geofenceService(self, didFailWithError: geofenceError)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[GEOFENCE] Error de ubicación: \(error.localizedDescription)")
        delegate?.geofenceService(self, didFailWithError: error)
    }
}

// MARK: - GeofenceServiceProtocol Extension
extension GeofenceService {
    var currentAuthorizationStatus: CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }
}
