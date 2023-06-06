//
//  ContentView.swift
//  Hisopy
//
//  Created by Denis on 15.03.2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var items: [Item]
    
    @State var search: String = ""

    var body: some View {
        if items.isEmpty {
            Text("No clipboard history")
                .frame(maxWidth: .infinity, minHeight: 300)
                .foregroundColor(.secondary)
        } else {
            VStack {
                Search(search: $search)
                    .padding([.leading, .top, .trailing], 15)
                FilteredList(search: search)
            }
            
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
