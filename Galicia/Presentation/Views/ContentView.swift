//
//  ContentView.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//

import SwiftUI
import CoreLocation

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var viewModel = BranchVisitViewModel()
    
    var body: some View {
        TabView {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Inicio", systemImage: "house.fill")
                }
            
            HistoryView(viewModel: viewModel)
                .tabItem {
                    Label("Historial", systemImage: "clock.fill")
                }
        }
        .accentColor(Color("BrandPrimary"))
        .sheet(isPresented: $viewModel.showServiceSelection) {
            ServiceSelectionView(viewModel: viewModel)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
