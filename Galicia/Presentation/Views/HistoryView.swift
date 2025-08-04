//
//  HistoryView.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: BranchVisitViewModel
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.visitHistory.isEmpty {
                    emptyStateView
                } else {
                    ForEach(viewModel.visitHistory, id: \.id) { visit in
                        VisitHistoryRow(visit: visit)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Historial de Visitas")
            .onAppear {
                viewModel.loadVisitHistory()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Sin visitas registradas")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Cuando visites una sucursal, aparecerá aquí")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .listRowBackground(Color.clear)
    }
}

// MARK: - Visit History Row
struct VisitHistoryRow: View {
    let visit: BranchVisit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(visit.entryTime.formatted(date: .abbreviated, time: .omitted))
                    .fontWeight(.semibold)
                
                Spacer()
                
                if let duration = visit.duration {
                    Text(formatDuration(duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                }
            }
            
            HStack(spacing: 16) {
                Label(visit.entryTime.formatted(date: .omitted, time: .shortened),
                      systemImage: "arrow.right.circle")
                .font(.caption)
                .foregroundColor(.green)
                
                if let exitTime = visit.exitTime {
                    Label(exitTime.formatted(date: .omitted, time: .shortened),
                          systemImage: "arrow.left.circle")
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
            
            if let service = visit.serviceType {
                Label(service.rawValue, systemImage: service.icon)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(_ name: String) {
        self.init(UIColor(named: name) ?? .systemOrange)
    }
}
