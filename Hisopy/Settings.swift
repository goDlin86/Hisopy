//
//  Settings.swift
//  Hisopy
//
//  Created by Denis on 22.04.2023.
//

import SwiftUI
import LaunchAtLogin
import KeyboardShortcuts

struct Settings: View {
    @AppStorage("maxItems") var maxItems = 10
    
    var body: some View {
        VStack {
            HStack {
                Text("Launch at login")
                Spacer()
                LaunchAtLogin.Toggle("")
            }
            HStack {
                Text("Open clipboard history")
                Spacer()
                KeyboardShortcuts.Recorder(for: .popup)
            }
            HStack {
                Text("Max items")
                Spacer()
                Stepper("\(maxItems)", value: $maxItems, in: 5...15)
            }
        }
        .padding(20)
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
