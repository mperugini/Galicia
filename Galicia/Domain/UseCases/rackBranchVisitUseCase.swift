//
//  rackBranchVisitUseCase.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//

import Foundation

final class TrackBranchVisitUseCase: TrackBranchVisitUseCaseProtocol {
    
    // MARK: - Properties
    private let repository: BranchVisitRepositoryProtocol
    private let notificationService: NotificationServiceProtocol
    private var currentVisit: BranchVisit?
    
    // MARK: - Initialization
    init(repository: BranchVisitRepositoryProtocol,
         notificationService: NotificationServiceProtocol) {
        self.repository = repository
        self.notificationService = notificationService
        loadActiveVisit()
    }
    
    // MARK: - Private Methods
    private func loadActiveVisit() {
        repository.fetchActiveVisit { [weak self] result in
            if case .success(let visit) = result {
                self?.currentVisit = visit
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return "\(hours) horas, \(minutes) minutos"
        } else if minutes > 0 {
            return "\(minutes) minutos, \(seconds) segundos"
        } else {
            return "\(seconds) segundos"
        }
    }
    
    // MARK: - TrackBranchVisitUseCaseProtocol
    func startVisit(at branch: Branch, completion: @escaping (Result<BranchVisit, Error>) -> Void) {
        print("[USECASE] Iniciando visita en sucursal: \(branch.name)")
        
        // Check if there's already an active visit
        if currentVisit != nil {
            print("[USECASE] Ya existe una visita activa, ignorando nueva entrada")
            // En lugar de fallar, devolvemos la visita existente
            completion(.success(currentVisit!))
            return
        }
        
        let visit = BranchVisit(branchId: branch.id)
        print("[USECASE] Creando nueva visita: \(visit.id)")
        
        repository.save(visit) { [weak self] result in
            switch result {
            case .success(let savedVisit):
                print("[USECASE] Visita guardada exitosamente")
                self?.currentVisit = savedVisit
                
                // Schedule entry notification
                let notification = GeofenceNotification.entryNotification(branch: branch)
                self?.notificationService.scheduleNotification(notification)
                print("[USECASE] Notificación de entrada programada")
                
                completion(.success(savedVisit))
                
            case .failure(let error):
                print("[USECASE] Error al guardar visita: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    func endVisit(completion: @escaping (Result<BranchVisit, Error>) -> Void) {
        print("[USECASE] Finalizando visita actual")
        
        guard var visit = currentVisit else {
            print("[USECASE] No hay visita activa para finalizar")
            completion(.failure(RepositoryError.notFound))
            return
        }
        
        visit.exitTime = Date()
        print("[USECASE] Tiempo de salida: \(visit.exitTime?.formatted() ?? "N/A")")
        
        repository.update(visit) { [weak self] result in
            switch result {
            case .success(let updatedVisit):
                print("[USECASE] Visita actualizada exitosamente")
                self?.currentVisit = nil
                
                // Schedule exit notification
                if let duration = updatedVisit.duration {
                    let branch = Branch.mainBranch // In real app, fetch from visit.branchId
                    let durationString = self?.formatDuration(duration) ?? ""
                    print("[USECASE] Duración de visita: \(durationString)")
                    let notification = GeofenceNotification.exitNotification(
                        branch: branch,
                        duration: durationString
                    )
                    self?.notificationService.scheduleNotification(notification)
                    print("[USECASE] Notificación de salida programada")
                }
                
                completion(.success(updatedVisit))
                
            case .failure(let error):
                print("[USECASE] Error al actualizar visita: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    func selectService(_ serviceType: ServiceType, completion: @escaping (Result<Void, Error>) -> Void) {
        guard var visit = currentVisit else {
            completion(.failure(RepositoryError.notFound))
            return
        }
        
        visit.serviceType = serviceType
        
        repository.update(visit) { [weak self] result in
            switch result {
            case .success(let updatedVisit):
                self?.currentVisit = updatedVisit
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getVisitHistory(completion: @escaping (Result<[BranchVisit], Error>) -> Void) {
        repository.fetchAll(completion: completion)
    }
}

// MARK: - Dependency Container
final class DependencyContainer {
    
    static let shared = DependencyContainer()
    
    // Services
    lazy var geofenceService: GeofenceServiceProtocol = GeofenceService()
    lazy var notificationService: NotificationServiceProtocol = NotificationService()
    lazy var analyticsService: AnalyticsServiceProtocol = AnalyticsService()
    lazy var pushNotificationService: PushNotificationServiceProtocol = PushNotificationService()
    
    // Repository
    lazy var branchVisitRepository: BranchVisitRepositoryProtocol = BranchVisitRepository()
    
    // Use Cases
    lazy var trackBranchVisitUseCase: TrackBranchVisitUseCaseProtocol = {
        TrackBranchVisitUseCase(
            repository: branchVisitRepository,
            notificationService: notificationService
        )
    }()
    
    lazy var analyticsUseCase: AnalyticsUseCaseProtocol = {
        AnalyticsUseCase(analyticsService: analyticsService)
    }()
    
    lazy var pushNotificationUseCase: PushNotificationUseCaseProtocol = {
        PushNotificationUseCase(
            pushNotificationService: pushNotificationService,
            analyticsUseCase: analyticsUseCase
        )
    }()
    
    private init() {}
}
