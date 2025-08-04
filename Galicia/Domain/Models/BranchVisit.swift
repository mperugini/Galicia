//
//  BranchVisit.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//

import Foundation

struct BranchVisit {
    let id: UUID
    let branchId: String
    let entryTime: Date
    var exitTime: Date?
    var duration: TimeInterval? {
        guard let exitTime = exitTime else { return nil }
        return exitTime.timeIntervalSince(entryTime)
    }
    var serviceType: ServiceType?
    
    init(id: UUID = UUID(), branchId: String, entryTime: Date = Date()) {
        self.id = id
        self.branchId = branchId
        self.entryTime = entryTime
    }
}
