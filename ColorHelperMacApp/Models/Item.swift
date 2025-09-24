//
//  ColorItem.swift
//  ColorHelperMacApp
//
//  Created by Steven mini on 2025/9/15.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class ColorItem: Identifiable {
    var hexCode: String
    var timestamp: Date
    var red: Double
    var green: Double
    var blue: Double
    var group: ColorGroup?

    init(color: Color, group: ColorGroup? = nil) {
        let nsColor = NSColor(color)
        let components = nsColor.usingColorSpace(.deviceRGB)

        let red = Double(components?.redComponent ?? 0.0)
        let green = Double(components?.greenComponent ?? 0.0)
        let blue = Double(components?.blueComponent ?? 0.0)

        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)

        self.red = red
        self.green = green
        self.blue = blue
        self.hexCode = String(format: "#%02X%02X%02X", r, g, b)
        self.timestamp = Date()
        self.group = group
    }

    init(hexCode: String, group: ColorGroup? = nil) {
        let processedHexCode = hexCode.hasPrefix("#") ? hexCode : "#\(hexCode)"
        let hex = processedHexCode.dropFirst()
        let scanner = Scanner(string: String(hex))
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
            self.red = Double((hexNumber & 0xFF0000) >> 16) / 255.0
            self.green = Double((hexNumber & 0x00FF00) >> 8) / 255.0
            self.blue = Double(hexNumber & 0x0000FF) / 255.0
        } else {
            self.red = 0.0
            self.green = 0.0
            self.blue = 0.0
        }

        self.hexCode = processedHexCode
        self.timestamp = Date()
        self.group = group
    }

    var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue)
    }
}
