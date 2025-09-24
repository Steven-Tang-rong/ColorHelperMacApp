//
//  MenuBarPopoverView.swift
//  ColorHelperMacApp
//
//  Created by Steven mini on 2025/9/15.
//

import SwiftUI
import SwiftData

struct MenuBarPopoverView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ColorItem.timestamp, order: .reverse) private var allColors: [ColorItem]
    @Query(sort: \ColorGroup.createdAt, order: .forward) private var groups: [ColorGroup]
    @StateObject private var colorPicker = ColorPickerService()
    @StateObject private var groupManager = GroupManager()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var currentGroup: ColorGroup?

    private var recentColors: [ColorItem] {
        if let currentGroup = currentGroup {
            let colors = currentGroup.colorItems.sorted { $0.timestamp > $1.timestamp }
            return Array(colors.prefix(20))
        } else {
            // Show all colors when no specific group is selected (limit to 20 for menu bar)
            return Array(allColors.prefix(20))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            Divider()

            if recentColors.isEmpty {
                emptyStateView
            } else {
                colorListView
            }

            Divider()
            footerSection
        }
        .frame(width: 280, height: 450)
        .background(Color(.windowBackgroundColor))
        .onAppear {
            colorPicker.setModelContext(modelContext)
            if currentGroup == nil {
                currentGroup = groupManager.getSelectedGroup(from: groups)
            }
            colorPicker.currentGroup = currentGroup
        }
        .onChange(of: currentGroup) { _, newGroup in
            if let newGroup = newGroup {
                groupManager.saveSelectedGroup(newGroup)
            } else {
                // Clear saved group when "All Colors" is selected
                UserDefaults.standard.removeObject(forKey: "selectedGroupId")
            }
            colorPicker.currentGroup = newGroup
        }
        .alert("Color Helper", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "paintpalette.fill")
                    .foregroundColor(.accentColor)
                Text("ColorHelper")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .padding(.top, 12)

            groupSelectorView

            Button(action: {
                colorPicker.startColorPicking()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "eyedropper")
                    Text("Pick Color")
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.bottom, 8)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "eyedropper")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text("No colors yet")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Click 'Pick Color' to start\ncollecting colors")
                .font(.caption)
                .foregroundColor(Color.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var colorListView: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(recentColors, id: \.id) { color in
                    ColorRowView(colorItem: color) {
                        copyColorToClipboard(color.hexCode)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
    }

    private var footerSection: some View {
        VStack(spacing: 4) {
            HStack {
                Text("\(recentColors.count)/20 recent colors")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Button("Open Main Window") {
                    openMainWindow()
                }
                .font(.caption)
                .foregroundColor(.accentColor)
            }

            HStack {
                if let currentGroup = currentGroup {
                    Text("From: \(currentGroup.name)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else {
                    Text("From: All Groups (\(allColors.count) total)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func copyColorToClipboard(_ hexCode: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(hexCode, forType: .string)

        alertMessage = "\(hexCode) copied!"
        showingAlert = true
    }

    private func openMainWindow() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        for window in NSApp.windows {
            if window.title == "ColorHelper" {
                window.makeKeyAndOrderFront(nil)
                return
            }
        }
    }
}

struct ColorRowView: View {
    let colorItem: ColorItem
    let onTap: () -> Void

    private var rgbString: String {
        let r = Int(colorItem.red * 255)
        let g = Int(colorItem.green * 255)
        let b = Int(colorItem.blue * 255)
        return "RGB(\(r), \(g), \(b))"
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(colorItem.swiftUIColor)
                    .frame(width: 30, height: 24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 0.5)
                    )

                VStack(alignment: .leading, spacing: 1) {
                    Text(colorItem.hexCode.uppercased())
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(.primary)

                    Text(rgbString)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)

                    Text(timeAgoText(from: colorItem.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "doc.on.doc")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color.clear)
        .contextMenu {
            Button("Copy Hex (\(colorItem.hexCode))") { onTap() }
            Button("Copy RGB (\(rgbString))") { copyRGB() }
        }
    }

    private func copyRGB() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(rgbString, forType: .string)
    }

    private func timeAgoText(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

extension MenuBarPopoverView {
    private var groupSelectorView: some View {
        Menu {
            // "All Colors" option
            Button(action: {
                currentGroup = nil
            }) {
                HStack {
                    Image(systemName: "paintpalette.fill")
                    Text("All Colors")
                    Spacer()
                    if currentGroup == nil {
                        Image(systemName: "checkmark")
                    }
                }
            }

            Divider()

            ForEach(groups, id: \.id) { group in
                Button(action: {
                    currentGroup = group
                }) {
                    HStack {
                        Image(systemName: group.isDefault ? "star.fill" : "folder")
                        Text(group.name)
                        Spacer()
                        if currentGroup?.id == group.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .contextMenu {
                    if !group.isDefault {
                        Button("Delete Group", role: .destructive) {
                            deleteGroup(group)
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: currentGroup == nil ? "paintpalette.fill" : (currentGroup?.isDefault == true ? "star.fill" : "folder"))
                    .foregroundColor(currentGroup == nil ? .accentColor : (currentGroup?.isDefault == true ? .orange : .accentColor))
                Text(currentGroup?.name ?? "All Colors")
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func deleteGroup(_ group: ColorGroup) {
        guard !group.isDefault else {
            alertMessage = "Cannot delete the default group"
            showingAlert = true
            return
        }

        modelContext.delete(group)
        if currentGroup?.id == group.id {
            currentGroup = groups.first { $0.isDefault } ?? groups.first
        }

        do {
            try modelContext.save()
            alertMessage = "Group deleted successfully"
            showingAlert = true
        } catch {
            alertMessage = "Failed to delete group: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}