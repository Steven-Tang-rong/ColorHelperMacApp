//
//  ColorCardView.swift
//  ColorHelperMacApp
//
//  Created by Steven mini on 2025/9/15.
//

import SwiftUI
import AppKit

struct ColorCardView: View {
    let colorItem: ColorItem
    let onTap: () -> Void
    let onDelete: () -> Void

    private var rgbString: String {
        let r = Int(colorItem.red * 255)
        let g = Int(colorItem.green * 255)
        let b = Int(colorItem.blue * 255)
        return "RGB(\(r), \(g), \(b))"
    }

    var body: some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 12)
                .fill(colorItem.swiftUIColor)
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                )

            VStack(spacing: 2) {
                Text(colorItem.hexCode.uppercased())
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(.sRGB, red: 0.3, green: 0.3, blue: 0.4))
                    .lineLimit(1)

                Text(rgbString)
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(.sRGB, red: 0.3, green: 0.3, blue: 0.4))
                    .lineLimit(1)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .onTapGesture {
            onTap()
        }
        .contextMenu {
            Button("Copy Hex (\(colorItem.hexCode))") { onTap() }
            Button("Copy RGB (\(rgbString))") { copyRGB() }
            Divider()
            Button("Delete", role: .destructive, action: onDelete)
        }
    }

    private func copyRGB() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(rgbString, forType: .string)
    }
}
