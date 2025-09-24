//
//  PreviewHelpers.swift
//  ColorHelperMacApp
//
//  Created by Steven mini on 2025/9/24.
//

import SwiftData
import SwiftUI

@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: ColorItem.self, ColorGroup.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        // 建立 Sample Groups
        let designGroup = ColorGroup(name: "Design System")
        let brandGroup = ColorGroup(name: "Brand Colors")
        let uiGroup = ColorGroup(name: "UI Components")
        [designGroup, brandGroup, uiGroup].forEach { context.insert($0) }

        // 建立 Sample Colors
        let sampleColors = [
            ColorItem(hexCode: "#FF6B6B", group: designGroup),
            ColorItem(hexCode: "#4ECDC4", group: designGroup),
            ColorItem(hexCode: "#5E17EB", group: brandGroup),
            ColorItem(hexCode: "#FFD700", group: brandGroup),
            ColorItem(hexCode: "#2C3E50", group: uiGroup),
            ColorItem(hexCode: "#27AE60", group: uiGroup)
        ]

        sampleColors.forEach { context.insert($0) }
        try context.save()

        return container
    } catch {
        fatalError("Failed to create preview container: \(error)")
    }
}()
