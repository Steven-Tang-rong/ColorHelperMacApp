//
//  GroupRowView.swift
//  ColorHelperMacApp
//
//  Created by Steven mini on 2025/9/15.
//

import SwiftUI

struct GroupRowView: View {
    let group: ColorGroup
    let isSelected: Bool
    let onTap: () -> Void
    let onDelete: () -> Void
    let onRename: (String) -> Void

    @State private var isEditing = false
    @State private var editingName = ""

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: group.isDefault ? "star.fill" : "folder")
                .foregroundColor(group.isDefault ? .orange : .accentColor)
                .frame(width: 16)

            if isEditing {
                TextField("Group name", text: $editingName)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit {
                        finishEditing()
                    }
                    .onAppear {
                        editingName = group.name
                    }
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text(group.name)
                        .font(.system(.body, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? .primary : .primary)
                        .lineLimit(1)

                    Text("\(group.colorCount) colors")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if isSelected && !isEditing {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentColor)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if !isEditing {
                onTap()
            }
        }
        .contextMenu {
            if !group.isDefault {
                Button("Rename") {
                    isEditing = true
                }
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            }
        }
    }

    private func finishEditing() {
        isEditing = false
        if !editingName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            onRename(editingName)
        }
        editingName = ""
    }
}