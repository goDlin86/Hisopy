//
//  HisopyApp.swift
//  Hisopy
//
//  Created by Denis on 15.03.2023.
//

import SwiftUI
import LaunchAtLogin
import KeyboardShortcuts

@main
struct HisopyApp: App {
    let persistenceController = PersistenceController.shared
    @Environment(\.openWindow) var openWindow
    
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
        
        MenuBarExtra("Hisopy", systemImage: "circle") {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            
            Divider()

            HStack {
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
            VStack {
                LaunchAtLogin.Toggle()
                KeyboardShortcuts.Recorder(for: .popup) {
                    Text("Open clipboard history")
                        .fixedSize()
                }
            }
            .padding(20)
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
