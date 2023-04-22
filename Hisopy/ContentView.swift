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
                .frame(maxWidth: .infinity, minHeight: 300)
                .foregroundColor(.secondary)
        } else {
            List {
                ForEach(items) { item in
                    Button(action: {
                        self.copyItem(item.text!)
                    }) {
                        HStack {
                            Text(item.text!)
                                .foregroundColor(Color(white: 0.85))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(realtiveDate.localizedString(for: item.firstCopiedAt!, relativeTo: .now))
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                    }
                    .buttonStyle(.borderless)
                    .background(item.pin ? .indigo : Color(white: 1, opacity: 0.1))
                    .opacity(self.hovered == item ? 0.75 : 1)
                    .cornerRadius(5)
                    .onHover { hover in
                        self.hovered = hover ? item : nil
                    }
                    .animation(.easeIn(duration: 0.15), value: hovered)
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
            .frame(minHeight: 300)
            
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

private let realtiveDate: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .short
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
