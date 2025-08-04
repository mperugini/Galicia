//
//  BranchVisitViewModel.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//

import Foundation
import CoreLocation
import Combine
import FirebaseAnalytics

// MARK: - Main ViewModel
final class BranchVisitViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentVisit: BranchVisit?
    @Published var isInsideBranch = false
    @Published var showServiceSelection = false
    @Published var visitHistory: [BranchVisit] = []
    @Published var errorMessage: String?
    @Published var locationPermissionStatus: CLAuthorizationStatus = .notDetermined
    
    // MARK: - Private Properties
    private let geofenceService: GeofenceServiceProtocol
    private let trackVisitUseCase: TrackBranchVisitUseCaseProtocol
    private let notificationService: NotificationServiceProtocol
    private let analyticsUseCase: AnalyticsUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(geofenceService: GeofenceServiceProtocol = DependencyContainer.shared.geofenceService,
         trackVisitUseCase: TrackBranchVisitUseCaseProtocol = DependencyContainer.shared.trackBranchVisitUseCase,
         notificationService: NotificationServiceProtocol = DependencyContainer.shared.notificationService,
         analyticsUseCase: AnalyticsUseCaseProtocol = DependencyContainer.shared.analyticsUseCase) {
        self.geofenceService = geofenceService
        self.trackVisitUseCase = trackVisitUseCase
        self.notificationService = notificationService
        self.analyticsUseCase = analyticsUseCase
        
        setupBindings()
        setupGeofence()
        loadVisitHistory()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Listen for notification to open service selection
        NotificationCenter.default.publisher(for: .openServiceSelection)
            .sink { [weak self] _ in
                self?.showServiceSelection = true
            }
            .store(in: &cancellables)
    }
    
    private func setupGeofence() {
        print("[VIEWMODEL] Configurando geofencing...")
        geofenceService.delegate = self
        geofenceService.requestLocationPermissions()
        notificationService.requestPermissions { _ in }
        
        // Iniciar monitoreo inmediatamente si ya tenemos permisos
        if geofenceService.currentAuthorizationStatus == .authorizedAlways {
            print("[VIEWMODEL] Permisos ya concedidos, iniciando monitoreo inmediato")
            startMonitoring()
        }
    }
    
    // MARK: - Public Methods
    func startMonitoring() {
        print("[VIEWMODEL] Iniciando monitoreo de sucursal: \(Branch.mainBranch.name)")
        geofenceService.startMonitoring(for: Branch.mainBranch)
        
        // Forzar verificación del estado actual
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            print("[VIEWMODEL] Verificando estado inicial después del inicio")
            self?.geofenceService.forceCheckCurrentState()
        }
    }
    
    func selectService(_ serviceType: ServiceType) {
        analyticsUseCase.logServiceSelected(serviceType: serviceType)
        
        trackVisitUseCase.selectService(serviceType) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.showServiceSelection = false
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func loadVisitHistory() {
        trackVisitUseCase.getVisitHistory { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let visits):
                    self?.visitHistory = visits
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Debug Methods
    func forceCheckCurrentState() {
        print("[VIEWMODEL] Forzando verificación de estado actual")
        geofenceService.forceCheckCurrentState()
        
        // También forzar una actualización de ubicación para calcular el estado
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.geofenceService.checkCurrentLocation()
        }
    }
    
    func checkCurrentLocation() {
        geofenceService.checkCurrentLocation()
    }
    
    func simulateExit() {
        print("[VIEWMODEL] Simulando salida de sucursal")
        if let _ = currentVisit {
            trackVisitUseCase.endVisit { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("[VIEWMODEL] Salida simulada exitosamente")
                        self?.currentVisit = nil
                        self?.isInsideBranch = false
                        self?.loadVisitHistory()
                    case .failure(let error):
                        print("[VIEWMODEL] Error en salida simulada: \(error.localizedDescription)")
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        } else {
            print("[VIEWMODEL] No hay visita activa para simular salida")
        }
    }
}

// MARK: - GeofenceServiceDelegate
extension BranchVisitViewModel: GeofenceServiceDelegate {
    
    func geofenceService(_ service: GeofenceServiceProtocol, didEnterRegion branch: Branch) {
        print("[VIEWMODEL] Usuario entró a sucursal: \(branch.name)")
        
        // Analytics event
        analyticsUseCase.logGeofenceEntered(branch: branch)
        
        trackVisitUseCase.startVisit(at: branch) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let visit):
                    print("[VIEWMODEL] Visita iniciada exitosamente")
                    self?.currentVisit = visit
                    self?.isInsideBranch = true
                    self?.showServiceSelection = true
                case .failure(let error):
                    print("[VIEWMODEL] Error al iniciar visita: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func geofenceService(_ service: GeofenceServiceProtocol, didExitRegion branch: Branch, duration: TimeInterval) {
        print("[VIEWMODEL] Usuario salió de sucursal: \(branch.name)")
        
        // Analytics event
        analyticsUseCase.logGeofenceExited(branch: branch, duration: duration)
        
        trackVisitUseCase.endVisit { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("[VIEWMODEL] Visita finalizada exitosamente")
                    self?.currentVisit = nil
                    self?.isInsideBranch = false
                    self?.loadVisitHistory()
                case .failure(let error):
                    print("[VIEWMODEL] Error al finalizar visita: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func geofenceService(_ service: GeofenceServiceProtocol, didUpdateLocation location: CLLocation) {
        // Could update UI with current location if needed
    }
    
    func geofenceService(_ service: GeofenceServiceProtocol, didFailWithError error: Error) {
        // Analytics event for errors
        analyticsUseCase.logError(error, context: "geofence_service")
        
        DispatchQueue.main.async { [weak self] in
            self?.errorMessage = error.localizedDescription
        }
    }
    
    func geofenceService(_ service: GeofenceServiceProtocol, didChangeAuthorization status: CLAuthorizationStatus) {
        print("[VIEWMODEL] Cambio de autorización: \(status.rawValue)")
        
        // Analytics event for permission changes
        analyticsUseCase.logLocationPermissionChanged(status: status)
        
        DispatchQueue.main.async { [weak self] in
            self?.locationPermissionStatus = status
            if status == .authorizedAlways {
                print("[VIEWMODEL] Permisos concedidos, iniciando monitoreo")
                self?.startMonitoring()
            } else {
                print("[VIEWMODEL] Permisos insuficientes: \(status.rawValue)")
            }
        }
    }
    

    
    func geofenceService(_ service: GeofenceServiceProtocol, didDetermineState state: CLRegionState, for branch: Branch) {
        print("[VIEWMODEL] Estado determinado: \(state.rawValue) para sucursal: \(branch.name)")
        
        // Analytics event for state determination
        analyticsUseCase.logGeofenceStateDetermined(state: state, for: branch)
        
        DispatchQueue.main.async { [weak self] in
            switch state {
            case .inside:
                print("[VIEWMODEL] Actualizando UI: Usuario DENTRO de sucursal")
                self?.isInsideBranch = true
                // Solo iniciar visita si no hay una activa
                if self?.currentVisit == nil {
                    self?.trackVisitUseCase.startVisit(at: branch) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let visit):
                                print("[VIEWMODEL] Visita iniciada desde estado determinado")
                                self?.currentVisit = visit
                                self?.showServiceSelection = true
                            case .failure(let error):
                                print("[VIEWMODEL] Error al iniciar visita desde estado: \(error.localizedDescription)")
                                self?.errorMessage = error.localizedDescription
                            }
                        }
                    }
                }
            case .outside:
                print("[VIEWMODEL] Actualizando UI: Usuario FUERA de sucursal")
                self?.isInsideBranch = false
                // Solo finalizar visita si hay una activa
                if let _ = self?.currentVisit {
                    self?.trackVisitUseCase.endVisit { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success:
                                print("[VIEWMODEL] Visita finalizada desde estado determinado")
                                self?.currentVisit = nil
                                self?.loadVisitHistory()
                            case .failure(let error):
                                print("[VIEWMODEL] Error al finalizar visita desde estado: \(error.localizedDescription)")
                                self?.errorMessage = error.localizedDescription
                            }
                        }
                    }
                }
            case .unknown:
                print("[VIEWMODEL] Estado desconocido para sucursal: \(branch.name)")
                break
            @unknown default:
                break
            }
        }
    }
    

}
