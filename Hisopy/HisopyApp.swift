//
//  HisopyApp.swift
//  Hisopy
//
//  Created by Denis on 15.03.2023.
//

import SwiftUI

@main
struct HisopyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
