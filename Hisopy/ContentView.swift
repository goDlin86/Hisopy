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
    @Environment(\.dismiss) var dismiss

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.pin, order: .reverse),
            SortDescriptor(\.firstCopiedAt, order: .reverse)
        ],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @State var hovered: Item?

    var body: some View {
        if items.isEmpty {
            Text("No clipboard history")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(.secondary)
        } else {
            List {
                ForEach(items) { item in
                    Button(action: {
                        self.copyItem(item.text ?? "")
                    }) {
                        Text(item.text ?? "")
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .background(self.hovered == item ? Color(red: 0.35, green: 0.35, blue: 0.35) : item.pin ? .indigo : .clear)
                    .cornerRadius(5)
                    .onHover { hover in
                        self.hovered = hover ? item : nil
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            pinItem(item)
                        } label: {
                            Label("Pin", systemImage: item.pin ? "pin.slash" : "pin")
                        }
                        .tint(.orange)
                    }
                }
                .onDelete(perform: deleteItems)
            }
        }
    }
    
    private func copyItem(_ string: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
        UserDefaults.standard.set(true, forKey: "ignoreOnlyNextEvent")
        Clipboard.shared.paste()
        NSApp.hide(self)
        dismiss()
    }
    
    private func pinItem(_ item: Item) {
        withAnimation {
            item.pin = !item.pin
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
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
