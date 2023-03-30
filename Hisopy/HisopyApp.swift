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
    @StateObject private var appState = AppState()
    @Environment(\.openWindow) var openWindow
    
    private let clipboard = Clipboard.shared

    var body: some Scene {
        MenuBarExtra("Hisopy", systemImage: "circle") {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
            
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
            .padding(.bottom, 2)
        }
        .defaultPosition(.bottomTrailing)
        .menuBarExtraStyle(.window)
        //.keyboardShortcut("b")
        
        Window("Settings", id: "Settings") {
            Group {
                LaunchAtLogin.Toggle()
                KeyboardShortcuts.Recorder(for: .popup) {
                    Text("Open paste history")
                        .fixedSize()
                }
            }
            .padding(20)
        }
        .windowResizability(.contentSize)
        
        Window("History menu", id: "HistoryMenu") {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appState)
                .frame(width: 300, height: 350)
        }
        .defaultPosition(.top)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}
