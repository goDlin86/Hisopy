//
//  Item.swift
//  Hisopy
//
//  Created by Denis on 25.01.2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var text: String
    var firstCopiedAt: Date
    var pin: Bool = false
    
    init(text: String, firstCopiedAt: Date) {
        self.text = text
        self.firstCopiedAt = firstCopiedAt
    }
}

extension Bool: Comparable {
    public static func < (lhs: Bool, rhs: Bool) -> Bool {
        return (lhs, rhs) == (false, true)
    }
}
