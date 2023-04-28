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

    @FetchRequest(sortDescriptors: [], animation: .default)
    private var items: FetchedResults<Item>
    
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
