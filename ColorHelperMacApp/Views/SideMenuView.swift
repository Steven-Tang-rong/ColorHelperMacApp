//
//  SideMenuView.swift
//  ColorHelperMacApp
//
//  Created by Steven mini on 2025/9/15.
//

import SwiftUI
import SwiftData

struct SideMenuView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ColorGroup.createdAt, order: .forward) private var groups: [ColorGroup]
    @Query(sort: \ColorItem.timestamp, order: .reverse) private var allColors: [ColorItem]
    @Binding var selectedGroup: ColorGroup?
    @StateObject private var groupManager = GroupManager()
    @State private var showingNewGroupSheet = false
    @State private var newGroupName = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            Divider()
            groupListSection
            Divider()
            footerSection
        }
        .frame(width: 220)
        .background(Color(NSColor.controlBackgroundColor))
        .onAppear {
            ensureDefaultGroupExists()
        }
        .onChange(of: selectedGroup) { _, newGroup in
            if let newGroup = newGroup {
                groupManager.saveSelectedGroup(newGroup)
            } else {
                // Clear saved group when "All Colors" is selected
                UserDefaults.standard.removeObject(forKey: "selectedGroupId")
            }
        }
        .sheet(isPresented: $showingNewGroupSheet) {
            newGroupSheet
        }
        .alert("Group Manager", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(.accentColor)
                Text("Color Groups")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            HStack {
                Text("\(groups.count) groups")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: {
                    showingNewGroupSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
                .help("Create New Group")
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
    }

    private var groupListSection: some View {
        ScrollView {
            LazyVStack(spacing: 2) {
                // "All Colors" option
                AllColorsRowView(
                    isSelected: selectedGroup == nil
                ) {
                    selectedGroup = nil
                }

                ForEach(groups, id: \.id) { group in
                    GroupRowView(
                        group: group,
                        isSelected: selectedGroup?.id == group.id
                    ) {
                        selectedGroup = group
                    } onDelete: {
                        deleteGroup(group)
                    } onRename: { newName in
                        renameGroup(group, to: newName)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var footerSection: some View {
        VStack(spacing: 8) {
            if let selectedGroup = selectedGroup {
                Text("\(selectedGroup.colorCount) colors in \"\(selectedGroup.name)\"")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
            } else {
                Text("\(allColors.count) colors in all groups")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 12)
    }

    private var newGroupSheet: some View {
        VStack(spacing: 20) {
            Text("Create New Group")
                .font(.headline)

            TextField("Group name", text: $newGroupName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    createNewGroup()
                }

            HStack {
                Button("Cancel") {
                    showingNewGroupSheet = false
                    newGroupName = ""
                }

                Spacer()

                Button("Create") {
                    createNewGroup()
                }
                .disabled(newGroupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 300, height: 150)
    }

    private func ensureDefaultGroupExists() {
        if groups.isEmpty {
            let defaultGroup = ColorGroup.createDefaultGroup(in: modelContext)
            selectedGroup = defaultGroup
            do {
                try modelContext.save()
            } catch {
                print("Failed to create default group: \(error)")
            }
        } else if selectedGroup == nil {
            selectedGroup = groupManager.getSelectedGroup(from: groups)
        }
    }

    private func createNewGroup() {
        let trimmedName = newGroupName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let newGroup = ColorGroup(name: trimmedName)
        modelContext.insert(newGroup)
        selectedGroup = newGroup

        do {
            try modelContext.save()
            showingNewGroupSheet = false
            newGroupName = ""
            alertMessage = "Group \"\(trimmedName)\" created successfully!"
            showingAlert = true
        } catch {
            alertMessage = "Failed to create group: \(error.localizedDescription)"
            showingAlert = true
        }
    }

    private func deleteGroup(_ group: ColorGroup) {
        guard !group.isDefault else {
            alertMessage = "Cannot delete the default group"
            showingAlert = true
            return
        }

        modelContext.delete(group)
        if selectedGroup?.id == group.id {
            selectedGroup = groups.first { $0.isDefault } ?? groups.first
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

    private func renameGroup(_ group: ColorGroup, to newName: String) {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, trimmedName != group.name else { return }

        group.name = trimmedName

        do {
            try modelContext.save()
            alertMessage = "Group renamed successfully"
            showingAlert = true
        } catch {
            alertMessage = "Failed to rename group: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

