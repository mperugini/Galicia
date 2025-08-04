//
//  GaliciaApp.swift
//  Galicia
//
//  Created by Mariano Perugini on 31/07/2025.
//

import SwiftUI
import Firebase

@main
struct GaliciaApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
