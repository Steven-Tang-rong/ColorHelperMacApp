//
//  ColorGroup.swift
//  ColorHelperMacApp
//
//  Created by Steven mini on 2025/9/15.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class ColorGroup: Identifiable {
    var name: String
    var createdAt: Date
    var isDefault: Bool
    @Relationship(deleteRule: .cascade, inverse: \ColorItem.group) var colorItems: [ColorItem] = []

    init(name: String, isDefault: Bool = false) {
        self.name = name
        self.createdAt = Date()
        self.isDefault = isDefault
    }

    var colorCount: Int {
        colorItems.count
    }

    static func createDefaultGroup(in context: ModelContext) -> ColorGroup {
        let defaultGroup = ColorGroup(name: "All Colors", isDefault: true)
        context.insert(defaultGroup)
        return defaultGroup
    }
}