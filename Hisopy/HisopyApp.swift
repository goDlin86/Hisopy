//
//  HisopyApp.swift
//  Hisopy
//
//  Created by Denis on 15.03.2023.
//

import SwiftUI

@main
struct HisopyApp: App {
    @Environment(\.openWindow) var openWindow
    
    private let persistenceController = PersistenceController.shared
    private let clipboard = Clipboard.shared
    private let pubOpen = NotificationCenter.default.publisher(for: NSNotification.Name("open"))

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
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            
            Divider()

            MenuButtons()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .menuBarExtraStyle(.window)
        
        Window("Settings", id: "Settings") {
            Settings()
        }
        .windowResizability(.contentSize)
        
        Window("Clipboard History", id: "History") {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .frame(width: 300, height: 350)
        }
        .defaultPosition(.center)
        .windowResizability(.contentSize)
    }
}
