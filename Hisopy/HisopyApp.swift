//
//  HisopyApp.swift
//  Hisopy
//
//  Created by Denis on 15.03.2023.
//

import SwiftUI
import SwiftData

@main
struct HisopyApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @Environment(\.openWindow) var openWindow
    
    private let clipboard = Clipboard.shared
    private let pubOpen = NotificationCenter.default.publisher(for: NSNotification.Name("open"))
    
    init() {
        clipboard.modelContext = sharedModelContainer.mainContext
    }
    
    var body: some Scene {
        //Hidden empty window for open History window by keyboard shortcut
        WindowGroup {
            EmptyView()
                .onReceive(pubOpen) { _ in
                    NSApp.activate(ignoringOtherApps: true)
                    openWindow(id: "History")
                }
                .frame(width: 0, height: 0)
        }
        .windowResizability(.contentSize)
        
        MenuBarExtra("Hisopy", systemImage: "command") {
            ContentView()
                .modelContainer(sharedModelContainer)
            
            Divider()

            MenuButtons()
                .modelContainer(sharedModelContainer)
        }
        .menuBarExtraStyle(.window)
        
        Window("Settings", id: "Settings") {
            Settings()
        }
        .windowResizability(.contentSize)
        
        Window("Clipboard History", id: "History") {
            ContentView()
                .frame(width: 300, height: 350)
        }
        .defaultPosition(.center)
        .windowResizability(.contentSize)
        .modelContainer(sharedModelContainer)
    }
}
