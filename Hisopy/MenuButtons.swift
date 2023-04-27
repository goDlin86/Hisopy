//
//  MenuButtons.swift
//  Hisopy
//
//  Created by Denis on 27.04.2023.
//

import SwiftUI

struct MenuButtons: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.openWindow) var openWindow
    @State private var showingAlert = false
    
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var items: FetchedResults<Item>
    
    var body: some View {
        HStack {
            Button(action: {
                showingAlert = true
            }) {
                Text("Clear history")
                    .foregroundColor(.white)
            }
            .confirmationDialog("Do you really want to delete the whole history?", isPresented: $showingAlert) {
                Button("OK") {
                    deleteAll()
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
    
    private func deleteAll() {
        withAnimation {
            items.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct MenuButtons_Previews: PreviewProvider {
    static var previews: some View {
        MenuButtons()
    }
}
