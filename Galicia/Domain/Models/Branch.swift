//
//  Branch.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//

import Foundation
import CoreLocation




// MARK: - Branch Model
struct Branch {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let radius: CLLocationDistance
    
    static let mainBranch = Branch(
        id: "galeria-branch",
        name: "Sucursal Saladillo",
        coordinate: CLLocationCoordinate2D(latitude: -35.6330328, longitude: -59.7783535),
        radius: 10.0
    )
    
    // Sucursal de prueba para testing (más lejana)
    static let testBranch = Branch(
        id: "test-branch",
        name: "Sucursal de Prueba",
        coordinate: CLLocationCoordinate2D(latitude: -35.64672601734939, longitude: -59.80101491680581),
        radius: 10.0
    )
}

// MARK: - Geofence State
enum GeofenceState {
    case inside
    case outside
    case unknown
}

// MARK: - Notification Content
struct GeofenceNotification {
    let title: String
    let body: String
    let userInfo: [String: Any]
    
    static func entryNotification(branch: Branch) -> GeofenceNotification {
        return GeofenceNotification(
            title: "Bienvenido a Banco Galicia",
            body: "Has ingresado a \(branch.name). ¿En qué podemos ayudarte?",
            userInfo: ["branchId": branch.id, "type": "entry"]
        )
    }
    
    static func exitNotification(branch: Branch, duration: String) -> GeofenceNotification {
        return GeofenceNotification(
            title: "Gracias por visitarnos",
            body: "Estuviste \(duration) en \(branch.name)",
            userInfo: ["branchId": branch.id, "type": "exit"]
        )
    }
}
