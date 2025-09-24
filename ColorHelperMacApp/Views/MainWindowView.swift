//
//  MainWindowView.swift
//  ColorHelperMacApp
//
//  Created by Steven mini on 2025/9/15.
//

import SwiftUI
import SwiftData

struct MainWindowView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ColorItem.timestamp, order: .reverse) private var allColors: [ColorItem]
    @StateObject private var colorPicker = ColorPickerService()
    @State private var newColorHex = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedColor: ColorItem?
    @State private var selectedGroup: ColorGroup?

    private var colors: [ColorItem] {
        if let selectedGroup = selectedGroup {
            return selectedGroup.colorItems.sorted { $0.timestamp > $1.timestamp }
        } else {
            return allColors
        }
    }

    let columns = [
        GridItem(.adaptive(minimum: 80, maximum: 120), spacing: 12)
    ]

    var body: some View {
        HStack(spacing: 0) {
            SideMenuView(selectedGroup: $selectedGroup)

            Divider()

            ZStack {
                LinearGradient(
                    colors: [
                        Color(NSColor.controlBackgroundColor),
                        Color(NSColor.windowBackgroundColor)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    headerView
                    colorInputSection

                    if let selectedColor = selectedColor {
                        colorDetailsSection(for: selectedColor)
                    }

                    colorGridView
                }
                .padding(30)
            }
        }
        .frame(width: 820, height: selectedColor != nil ? 600 : 500)
        .onAppear {
            colorPicker.setModelContext(modelContext)
        }
        .onChange(of: selectedGroup) { _, newGroup in
            colorPicker.currentGroup = newGroup
        }
        .onChange(of: colorPicker.lastPickedColor) { _, newColor in
            if let newColor = newColor {
                selectedColor = newColor
            }
        }
        .alert("Color Helper", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(selectedGroup?.name ?? "All Colors")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    //.foregroundColor(Color(.sRGB, red: 0.2, green: 0.2, blue: 0.3))

                Text("\(colors.count) colors in this group")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {
                colorPicker.startColorPicking()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "eyedropper")
                    Text("Pick Color")
                }
                .font(.system(.body, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [
                            Color(.sRGB, red: 1.0, green: 0.6, blue: 1.0),
                            Color(.sRGB, red: 0.2, green: 0.4, blue: 0.8)
                        ],
                        startPoint: .top,
                        endPoint: .bottomLeading
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    private var colorInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Add Color Manually")
                .font(.headline)
                .foregroundColor(Color(.sRGB, red: 0.3, green: 0.3, blue: 0.4))

            HStack {
                TextField("Enter hex code (e.g., #FF5733 or FF5733)", text: $newColorHex)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(Color.black)
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1.5)
                            .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Button(action: {
                    addColorManually()
                }) {
                    Image(systemName: "rectangle.badge.plus").font(.largeTitle).foregroundStyle(Color.accentColor)
                    //Text("Add Color")
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }

    private var colorGridView: some View {
        ScrollView {
            if colors.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "paintpalette")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text("No colors saved yet")
                        .font(.title2)
                        .foregroundColor(.secondary)

                    Text("Use the eyedropper tool or add colors manually to get started")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(40)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(colors, id: \.id) { color in
                        ColorCardView(colorItem: color) {
                            selectedColor = color
                        } onDelete: {
                            deleteColor(color)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.5))
                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
        )
    }

    private func colorDetailsSection(for color: ColorItem) -> some View {
        let rgbString = "RGB(\(Int(color.red * 255)), \(Int(color.green * 255)), \(Int(color.blue * 255)))"

        return VStack(alignment: .leading, spacing: 12) {
            Text("Selected Color")
                .font(.headline)
                .foregroundColor(Color(.sRGB, red: 0.3, green: 0.3, blue: 0.4))

            HStack(spacing: 16) {
                // Large color preview
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.swiftUIColor)
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black.opacity(0.1), lineWidth: 2)
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    )

                VStack(alignment: .leading, spacing: 8) {
                    // HEX value
                    VStack(alignment: .leading, spacing: 4) {
                        Text("HEX")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.sRGB, red: 0.4, green: 0.4, blue: 0.5))

                        HStack {
                            Text(color.hexCode.uppercased())
                                .font(.system(.title3, design: .monospaced, weight: .semibold))
                                .foregroundColor(Color.black)
                                .textSelection(.enabled)

                            Button(action: {
                                copyToClipboard(color.hexCode, message: "HEX color \(color.hexCode) copied!")
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .font(.caption)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .help("Copy HEX")
                        }
                    }

                    // RGB value
                    VStack(alignment: .leading, spacing: 4) {
                        Text("RGB")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.sRGB, red: 0.4, green: 0.4, blue: 0.5))

                        HStack {
                            Text(rgbString)
                                .font(.system(.title3, design: .monospaced, weight: .semibold))
                                .foregroundColor(Color.black)
                                .textSelection(.enabled)

                            Button(action: {
                                copyToClipboard(rgbString, message: "RGB color \(rgbString) copied!")
                            }) {
                                Image(systemName: "doc.on.doc")
                                    .font(.caption)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .help("Copy RGB")
                        }
                    }
                }

                Spacer()

                Button("Clear Selection") {
                    selectedColor = nil
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(Color(.sRGB, red: 0.4, green: 0.4, blue: 0.5))
                .font(.caption)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.8))
                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
        )
        .transition(.scale.combined(with: .opacity))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedColor)
    }

    private func copyToClipboard(_ text: String, message: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)

        alertMessage = message
        showingAlert = true
    }

    private func addColorManually() {
        let trimmedHex = newColorHex.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedHex.isEmpty else { return }

        let hexPattern = "^#?([A-Fa-f0-9]{6})$"
        let regex = try? NSRegularExpression(pattern: hexPattern)
        let range = NSRange(location: 0, length: trimmedHex.utf16.count)

        if regex?.firstMatch(in: trimmedHex, options: [], range: range) != nil {
            let colorItem = ColorItem(hexCode: trimmedHex, group: selectedGroup)
            modelContext.insert(colorItem)

            do {
                try modelContext.save()
                newColorHex = ""
                selectedColor = colorItem
                copyToClipboard(colorItem.hexCode, message: "Color \(colorItem.hexCode) added and copied!")
            } catch {
                alertMessage = "Failed to save color: \(error.localizedDescription)"
                showingAlert = true
            }
        } else {
            alertMessage = "Invalid hex color format. Use format like #FF5733 or FF5733"
            showingAlert = true
        }
    }


    private func deleteColor(_ color: ColorItem) {
        modelContext.delete(color)

        do {
            try modelContext.save()
        } catch {
            alertMessage = "Failed to delete color: \(error.localizedDescription)"
            showingAlert = true
        }
    }
        
}

// MARK: - Preview
#Preview {
    MainWindowView()
        .environmentObject(ColorPickerService())
}

// MARK: - Preview Helper Extensions
#Preview {
    MainWindowView()
        .modelContainer(previewContainer)
        .environmentObject(ColorPickerService())
}

