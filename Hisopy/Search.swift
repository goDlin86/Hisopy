//
//  Search.swift
//  Hisopy
//
//  Created by Denis on 27.04.2023.
//

import SwiftUI

struct Search: View {   
    @Binding var search: String
    @FocusState private var searchIsFocused: Bool
    
    var body: some View {
        ZStack(alignment: .trailing) {
            TextField("Search", text: $search)
                .focused($searchIsFocused)
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .onAppear {
                    DispatchQueue.main.async {
                        searchIsFocused = false
                    }
                }
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.secondary)
                .opacity(search.isEmpty ? 0 : 1)
                .animation(.easeIn, value: search.isEmpty)
                .offset(x: -5)
                .onTapGesture {
                    search = ""
                    searchIsFocused = false
                }
                .onContinuousHover { phase in
                    switch phase {
                    case .active(_):
                        NSCursor.arrow.push()
                    case .ended:
                        NSCursor.pop()
                    }
                }
        }
            
    }
}

struct Search_Previews: PreviewProvider {
    static var previews: some View {
        Search(search: .constant(""))
            .padding()
    }
}
