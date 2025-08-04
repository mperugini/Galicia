//
//  HomeView.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//
import SwiftUI
import CoreLocation

struct HomeView: View {
    @ObservedObject var viewModel: BranchVisitViewModel
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Status Card
                statusCard
                    .padding()
                
                // Branch Info
                branchInfoCard
                    .padding(.horizontal)
                
                Spacer()
                
                // Permission Status
                if viewModel.locationPermissionStatus != .authorizedAlways {
                    permissionCard
                        .padding()
                }
                
                // Debug Button (solo para desarrollo)
                #if DEBUG
                debugButton
                    .padding()
                #endif
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Image("galicia-logo")
                .resizable()
                .scaledToFit()
                .frame(height: 40)
                .padding(.top, 50)
            
            Text("Bienvenido")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Text(viewModel.isInsideBranch ? "Estás en la sucursal" : "Fuera de la sucursal")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 20)
        .background(
            LinearGradient(
                colors: [Color("BrandPrimary"), Color("DarkOrange")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var statusCard: some View {
        VStack(spacing: 16) {
            HStack {
                Circle()
                    .fill(viewModel.isInsideBranch ? Color.green : Color.gray)
                    .frame(width: 12, height: 12)
                
                Text(viewModel.isInsideBranch ? "Dentro del geofence" : "Fuera del geofence")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            if let visit = viewModel.currentVisit {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Entrada: \(visit.entryTime.formatted(date: .omitted, time: .shortened))",
                          systemImage: "arrow.right.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
                    
                    if let service = visit.serviceType {
                        Label("Servicio: \(service.rawValue)",
                              systemImage: service.icon)
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
    
    private var branchInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "building.2.fill")
                    .foregroundColor(Color("BrandPrimary"))
                Text("Sucursal Galería")
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Label("Av. Galería 123", systemImage: "location.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Label("Lun-Vie: 10:00 - 15:00", systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
    
    private var permissionCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "location.slash.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text("Permisos de ubicación requeridos")
                .font(.headline)
            
            Text("Para detectar tu entrada a la sucursal, necesitamos acceso a tu ubicación 'Siempre'")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: openSettings) {
                Text("Ir a Configuración")
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("BrandPrimary"))
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    private var debugButton: some View {
        VStack(spacing: 12) {
            Button("🔍 Verificar Estado Actual") {
                viewModel.forceCheckCurrentState()
            }
            .fontWeight(.medium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(10)
            
            Button("📍 Obtener Ubicación") {
                viewModel.checkCurrentLocation()
            }
            .fontWeight(.medium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .cornerRadius(10)
            
            Button("🚪 Simular Salida") {
                viewModel.simulateExit()
            }
            .fontWeight(.medium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .cornerRadius(10)
            
            Button("🔄 Actualizar Estado") {
                viewModel.forceCheckCurrentState()
            }
            .fontWeight(.medium)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange)
            .cornerRadius(10)
            
            Text("Estado actual: \(viewModel.isInsideBranch ? "DENTRO" : "FUERA")")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
    }
}
