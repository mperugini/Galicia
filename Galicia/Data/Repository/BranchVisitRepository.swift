//
//  BranchVisitRepository.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//
import CoreData
import Foundation

final class BranchVisitRepository: BranchVisitRepositoryProtocol {
    
    private let coreDataManager: CoreDataManager
    private let context: NSManagedObjectContext
    
    init(coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
        self.context = coreDataManager.persistentContainer.viewContext
    }
    
    func save(_ visit: BranchVisit, completion: @escaping (Result<BranchVisit, Error>) -> Void) {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let entity = NSEntityDescription.entity(forEntityName: "BranchVisitEntity", in: self.context)!
            let visitEntity = NSManagedObject(entity: entity, insertInto: self.context)
            
            visitEntity.setValue(visit.id, forKey: "id")
            visitEntity.setValue(visit.branchId, forKey: "branchId")
            visitEntity.setValue(visit.entryTime, forKey: "entryTime")
            visitEntity.setValue(visit.exitTime, forKey: "exitTime")
            visitEntity.setValue(visit.serviceType?.rawValue, forKey: "serviceType")
            visitEntity.setValue(Date(), forKey: "createdAt")
            visitEntity.setValue(Date(), forKey: "updatedAt")
            
            do {
                try self.context.save()
                completion(.success(visit))
            } catch {
                completion(.failure(RepositoryError.saveFailed))
            }
        }
    }
    
    func update(_ visit: BranchVisit, completion: @escaping (Result<BranchVisit, Error>) -> Void) {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "BranchVisitEntity")
            request.predicate = NSPredicate(format: "id == %@", visit.id as CVarArg)
            request.fetchLimit = 1
            
            do {
                guard let visitEntity = try self.context.fetch(request).first else {
                    completion(.failure(RepositoryError.notFound))
                    return
                }
                
                visitEntity.setValue(visit.exitTime, forKey: "exitTime")
                visitEntity.setValue(visit.serviceType?.rawValue, forKey: "serviceType")
                visitEntity.setValue(Date(), forKey: "updatedAt")
                
                try self.context.save()
                completion(.success(visit))
            } catch {
                completion(.failure(RepositoryError.updateFailed))
            }
        }
    }
    
    func fetchAll(completion: @escaping (Result<[BranchVisit], Error>) -> Void) {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "BranchVisitEntity")
            request.sortDescriptors = [NSSortDescriptor(key: "entryTime", ascending: false)]
            
            do {
                let entities = try self.context.fetch(request)
                let visits = entities.compactMap { self.mapToVisit(from: $0) }
                completion(.success(visits))
            } catch {
                completion(.failure(RepositoryError.fetchFailed))
            }
        }
    }
    
    func fetchActiveVisit(completion: @escaping (Result<BranchVisit?, Error>) -> Void) {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "BranchVisitEntity")
            request.predicate = NSPredicate(format: "exitTime == nil")
            request.fetchLimit = 1
            
            do {
                let entities = try self.context.fetch(request)
                let visit = entities.first.flatMap { self.mapToVisit(from: $0) }
                completion(.success(visit))
            } catch {
                completion(.failure(RepositoryError.fetchFailed))
            }
        }
    }
    
    func deleteAll(completion: @escaping (Result<Void, Error>) -> Void) {
        context.perform { [weak self] in
            guard let self = self else { return }
            
            let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "BranchVisitEntity")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try self.context.execute(deleteRequest)
                try self.context.save()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    private func mapToVisit(from entity: NSManagedObject) -> BranchVisit? {
        guard let id = entity.value(forKey: "id") as? UUID,
              let branchId = entity.value(forKey: "branchId") as? String,
              let entryTime = entity.value(forKey: "entryTime") as? Date else {
            return nil
        }
        
        var visit = BranchVisit(id: id, branchId: branchId, entryTime: entryTime)
        visit.exitTime = entity.value(forKey: "exitTime") as? Date
        
        if let serviceTypeRaw = entity.value(forKey: "serviceType") as? String {
            visit.serviceType = ServiceType(rawValue: serviceTypeRaw)
        }
        
        return visit
    }
}
