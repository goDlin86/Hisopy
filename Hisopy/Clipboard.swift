//
//  Clipboard.swift
//  Hisopy
//
//  Created by Denis on 16.03.2023.
//

import SwiftUI
import SwiftData
import KeyboardShortcuts

class Clipboard {
    static let shared = Clipboard()
    
    var changeCount: Int

    private let pasteboard = NSPasteboard.general
    private let timerInterval = 1.0
    
    private let supportedTypes: Set<NSPasteboard.PasteboardType> = [
        //.fileURL,
        //.html,
        //.png,
        //.rtf,
        .string,
        //.tiff
    ]
    
    var modelContext: ModelContext?
    private var maxItems: Int { UserDefaults.standard.integer(forKey: "maxItems") }
       
    init() {
        UserDefaults.standard.register(defaults: [
            "maxItems": 10
        ])
        
        changeCount = pasteboard.changeCount
        
        KeyboardShortcuts.reset(.popup)
        KeyboardShortcuts.onKeyDown(for: .popup) {
            NotificationCenter.default.post(name: NSNotification.Name("open"), object: nil)
        }
        
        Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { t in
            self.checkForChangesInPasteboard()
        }
    }
    
    func checkForChangesInPasteboard() {
        guard self.pasteboard.changeCount != self.changeCount else {
            return
        }
        
        changeCount = pasteboard.changeCount
        
        if UserDefaults.standard.bool(forKey: "ignoreOnlyNextEvent") {
            UserDefaults.standard.set(false, forKey: "ignoreOnlyNextEvent")
            return
        }
        
        if (Set(pasteboard.types ?? []).isDisjoint(with: supportedTypes)) {
            return
        }
        
        pasteboard.pasteboardItems?.forEach({ item in
            let types = Set(item.types)
            if types.contains(.string) {
                if isEmptyString(item) && !richText(item) {
                    return
                }
                
                let newItem = Item(text: item.string(forType: .string)!, firstCopiedAt: Date())
                modelContext?.insert(newItem)
            }
        })
        
        let fetchRequest = FetchDescriptor<Item>(
            predicate: #Predicate { !$0.pin },
            sortBy: [SortDescriptor(\.firstCopiedAt, order: .reverse)]
        )
        
        if let modelContext {
            do {
                var items = try modelContext.fetch(fetchRequest)
                items.suffix(from: 1).filter { $0.text == items[0].text }.forEach(modelContext.delete)
                
                try modelContext.save()
                
                items = try modelContext.fetch(fetchRequest)
                if items.count > maxItems {
                    items.suffix(from: maxItems).forEach(modelContext.delete)
                }
                
                try modelContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
      
    private func isEmptyString(_ item: NSPasteboardItem) -> Bool {
        guard let string = item.string(forType: .string) else {
            return true
        }

        return string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func richText(_ item: NSPasteboardItem) -> Bool {
        if let rtf = item.data(forType: .rtf) {
            if let attributedString = NSAttributedString(rtf: rtf, documentAttributes: nil) {
                return !attributedString.string.isEmpty
            }
        }

        if let html = item.data(forType: .html) {
            if let attributedString = NSAttributedString(html: html, documentAttributes: nil) {
                return !attributedString.string.isEmpty
            }
        }

        return false
    }
    
    // Based on https://github.com/Clipy/Clipy/blob/develop/Clipy/Sources/Services/PasteService.swift.
    func paste() {
        DispatchQueue.main.async {
            // Add flag that left/right modifier key has been pressed.
            // See https://github.com/TermiT/Flycut/pull/18 for details.
            //let cmdFlag = CGEventFlags(rawValue: UInt64(KeyChord.pasteKeyModifiers.rawValue) | 0x000008)
            //var vCode = Sauce.shared.keyCode(for: KeyChord.pasteKey)

            // Force QWERTY keycode when keyboard layout switches to
            // QWERTY upon pressing ⌘ key (e.g. "Dvorak - QWERTY ⌘").
            // See https://github.com/p0deje/Maccy/issues/482 for details.
            //if KeyboardLayout.current.commandSwitchesToQWERTY && cmdFlag.contains(.maskCommand) {
            //    vCode = KeyChord.pasteKey.QWERTYKeyCode
            //}

            let source = CGEventSource(stateID: .combinedSessionState)
            // Disable local keyboard events while pasting
            source?.setLocalEventsFilterDuringSuppressionState([.permitLocalMouseEvents, .permitSystemDefinedEvents],
                                                               state: .eventSuppressionStateSuppressionInterval)

            let keyVDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
            let keyVUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
            keyVDown?.flags = .maskCommand
            keyVUp?.flags = .maskCommand
            keyVDown?.post(tap: .cgAnnotatedSessionEventTap)
            keyVUp?.post(tap: .cgAnnotatedSessionEventTap)
        }
    }
}
