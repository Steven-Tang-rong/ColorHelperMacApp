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
        VStack(spacing: 0) {
            UnevenRoundedRectangle(
                topLeadingRadius: 24,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 24
            )
            .fill(colorItem.swiftUIColor)
            .frame(height: 60)

            if colorItem.hexCode.replacingOccurrences(of: "#", with: "").uppercased() == "FFFFFF" {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 0.5)
            }


            Text(colorItem.hexCode.uppercased())
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(Color(.sRGB, red: 0.3, green: 0.3, blue: 0.4))
                .lineLimit(1)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
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
