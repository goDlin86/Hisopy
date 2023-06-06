//
//  FilteredList.swift
//  Hisopy
//
//  Created by Denis on 28.04.2023.
//

import SwiftUI
import SwiftData

struct FilteredList: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
       
    @Query private var items: [Item]
    
    @State var hovered: Item?
    
    init(search: String) {
        _items = Query(
            filter: #Predicate { !search.isEmpty ? $0.text.contains(search) : true },
            sort: [
                SortDescriptor(\.pin, order: .reverse),
                SortDescriptor(\.firstCopiedAt, order: .reverse)
            ],
            animation: .default
        )
    }
    
    var body: some View {
        if items.isEmpty {
            Text("Not found")
                .frame(maxWidth: .infinity, minHeight: 300)
                .foregroundColor(.secondary)
        } else {
            List {
                ForEach(items) { item in
                    Button(action: {
                        self.copyItem(item.text)
                    }) {
                        HStack {
                            Text(item.text)
                                .foregroundColor(Color(white: 0.85))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(relativeDate.localizedString(for: item.firstCopiedAt, relativeTo: .now))
                                .font(.subheadline)
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                    }
                    .buttonStyle(.borderless)
                    .background(item.pin ? .indigo : Color(white: 1, opacity: 0.1))
                    .opacity(self.hovered == item ? 0.75 : 1)
                    .overlay(
                        Divider(), alignment: .top
                    )
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
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
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

private let relativeDate: RelativeDateTimeFormatter = {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .short
    return formatter
}()

#Preview {
    FilteredList(search: "ssda")
        .modelContainer(for: Item.self, inMemory: true)
}
