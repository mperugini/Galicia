//
//  ServiceSelectionViewModel.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//

import Foundation

final class ServiceSelectionViewModel: ObservableObject {
    
    @Published var services = ServiceType.allCases
    @Published var selectedService: ServiceType?
    @Published var isLoading = false
    
    let onServiceSelected: (ServiceType) -> Void
    
    init(onServiceSelected: @escaping (ServiceType) -> Void) {
        self.onServiceSelected = onServiceSelected
    }
    
    func selectService(_ service: ServiceType) {
        selectedService = service
        isLoading = true
        
        // Simulate API call delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isLoading = false
            self?.onServiceSelected(service)
        }
    }
}
