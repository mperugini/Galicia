//
//  ServiceType.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//

import Foundation

enum ServiceType: String, CaseIterable {
    case teller = "Atención por caja"
    case personalizedService = "Atención personalizada"
    case personalLoans = "Créditos Personales"
    case other = "Otros trámites"
    
    var icon: String {
        switch self {
        case .teller: return "banknote"
        case .personalizedService: return "person.2"
        case .personalLoans: return "creditcard"
        case .other: return "doc.text"
        }
    }
}
