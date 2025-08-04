//
//  ServiceSelectionView.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//

import SwiftUI

struct ServiceSelectionView: View {
    @ObservedObject var viewModel: BranchVisitViewModel
    @StateObject private var selectionViewModel: ServiceSelectionViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: BranchVisitViewModel) {
        self.viewModel = viewModel
        self._selectionViewModel = StateObject(wrappedValue: ServiceSelectionViewModel { service in
            viewModel.selectService(service)
        })
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color("BrandPrimary"))
                        .padding(.top, 20)
                    
                    Text("¿En qué podemos ayudarte?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Selecciona el servicio que necesitas")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 30)
                
                // Services Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(selectionViewModel.services, id: \.self) { service in
                        ServiceCard(
                            service: service,
                            isSelected: selectionViewModel.selectedService == service,
                            action: { selectionViewModel.selectService(service) }
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
            .overlay {
                if selectionViewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
        }
    }
}


// MARK: - Service Card Component
struct ServiceCard: View {
    let service: ServiceType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: service.icon)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .white : Color("BrandPrimary"))
                
                Text(service.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color("BrandPrimary") : Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
