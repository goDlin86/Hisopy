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

            HStack {
                Button(action: {
                    let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
                    
                    do {
                        let items = try persistenceController.container.viewContext.fetch(fetchRequest)
                        items.forEach(persistenceController.container.viewContext.delete)
                        
                        try persistenceController.container.viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                }) {
                    Text("Clear history")
                        .foregroundColor(.white)
                }
                Button(action: {
                    NSApp.activate(ignoringOtherApps: true)
                    openWindow(id: "Settings")
                }) {
                    Text("Settings")
                        .foregroundColor(.white)
                }
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Text("Quit")
                        .foregroundColor(.white)
                }
                .keyboardShortcut("q")
            }
            .padding(.bottom, 7)
        }
        .menuBarExtraStyle(.window)
        
        Window("Settings", id: "Settings") {
            Settings()
        }
        .windowResizability(.contentSize)
        
        Window("Clipboard History", id: "History") {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .frame(width: 300, height: 300)
        }
        .defaultPosition(.center)
        .windowResizability(.contentSize)
    }
}
