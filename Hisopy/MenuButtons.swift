//
//  MenuButtons.swift
//  Hisopy
//
//  Created by Denis on 27.04.2023.
//

import SwiftUI
import SwiftData

struct MenuButtons: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) var openWindow
    @State private var showingAlert = false
    
    @Query private var items: [Item]
    
    var body: some View {
        HStack {
            Button(action: {
                showingAlert = true
            }) {
                Text("Clear history")
                    .foregroundColor(.white)
            }
            .confirmationDialog("Do you really want to delete the whole history?", isPresented: $showingAlert) {
                Button("Delete all") {
                    withAnimation {
                        items.forEach(modelContext.delete)
                    }
                }
                Button("Cancel", role: .cancel) {}
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
}

#Preview {
    MenuButtons()
}
