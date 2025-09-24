//
//  ColorPickerService.swift
//  ColorHelperMacApp
//
//  Created by Steven mini on 2025/9/15.
//

import SwiftUI
import AppKit
import SwiftData
import UserNotifications

class ColorPickerService: ObservableObject {
    @Published var isPickingColor = false
    @Published var lastPickedColor: ColorItem?
    private var modelContext: ModelContext?
    var currentGroup: ColorGroup?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func startColorPicking() {
        guard !isPickingColor else { return }

        isPickingColor = true

        let colorSampler = NSColorSampler()
        colorSampler.show { [weak self] selectedColor in
            DispatchQueue.main.async {
                self?.isPickingColor = false

                if let color = selectedColor, let context = self?.modelContext {
                    let colorItem = ColorItem(color: Color(nsColor: color), group: self?.currentGroup)
                    context.insert(colorItem)

                    do {
                        try context.save()
                        self?.lastPickedColor = colorItem
                    } catch {
                        print("Failed to save color: \(error)")
                    }

                    self?.copyToClipboard(colorItem.hexCode)
                }
            }
        }
    }

    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        showNotification(message: "Color \(text) copied to clipboard")
    }

    private func showNotification(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "ColorHelper"
        content.body = message
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to show notification: \(error)")
            }
        }
    }
}