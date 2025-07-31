//
//  GaliciaApp.swift
//  Galicia
//
//  Created by Mariano Peruginoi on 31/07/2025.
//

import SwiftUI

@main
struct GaliciaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
