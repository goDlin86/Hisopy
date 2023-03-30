//
//  Clipboard.swift
//  Hisopy
//
//  Created by Denis on 16.03.2023.
//

import SwiftUI
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
    
    private let viewContext = PersistenceController.shared.container.viewContext
    private let maxItem = 10
    
    private var extraVisibleWindows: [NSWindow] {
        return NSApp.windows.filter({ $0.isVisible && String(describing: type(of: $0)) != "NSStatusBarWindow" })
    }
    
    @Environment(\.openWindow) var openWindow
       
    init() {
        changeCount = pasteboard.changeCount
        KeyboardShortcuts.reset(.popup)
        KeyboardShortcuts.onKeyDown(for: .popup) {
            self.popup()
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
            if types.contains(.string) && isEmptyString(item) && !richText(item) {
                return
            }
            
            let newItem = Item(context: viewContext)
            newItem.text = item.string(forType: .string)
            newItem.firstCopiedAt = Date()
        })
        
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Item.firstCopiedAt, ascending: false)]
        
        do {
            let items = try viewContext.fetch(fetchRequest)
            if items.count > maxItem {
                items.suffix(from: maxItem).forEach(viewContext.delete)
            }
        
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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
    
    func popup() {
        //let windowFrame = NSWorkspace.shared.frontmostApplication?.window
        
        withFocus {
            if let frame = NSScreen.main?.visibleFrame {
                //self.openWindow(id: "HistoryMenu")
            }
        }
    }
    
    private func withFocus(_ closure: @escaping () -> Void) {
        //KeyboardShortcuts.disable(.popup)

        NSApp.activate(ignoringOtherApps: true)
        Timer.scheduledTimer(withTimeInterval: 0.04, repeats: false) { _ in
            closure()
            //KeyboardShortcuts.enable(.popup)
            if self.extraVisibleWindows.count == 0 {
                NSApp.hide(self)
            }
        }
    }
}
