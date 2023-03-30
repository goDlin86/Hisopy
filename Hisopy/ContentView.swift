//
//  ContentView.swift
//  Hisopy
//
//  Created by Denis on 15.03.2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var appState: AppState

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.firstCopiedAt, ascending: false)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State var hovered: Item?

    var body: some View {
        List {
            ForEach(items) { item in
                Button(action: {
                    self.copyItem(item.text ?? "")
                }) {
                    Text(item.text ?? "")
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .background(self.hovered == item ? Color(red: 0.35, green: 0.35, blue: 0.35) : .clear)
                .cornerRadius(5)
                .onHover { hover in
                    if hover {
                        self.hovered = item
                    } else {
                        self.hovered = nil
                    }
                }
            }
            .onDelete(perform: deleteItems)
        }
    }
    
    private func copyItem(_ string: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
        UserDefaults.standard.set(true, forKey: "ignoreOnlyNextEvent")
        Clipboard.shared.paste()
        NSApp.hide(self)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
