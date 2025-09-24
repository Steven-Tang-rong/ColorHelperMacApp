//
//  GroupManager.swift
//  ColorHelperMacApp
//
//  Created by Steven mini on 2025/9/15.
//

import Foundation
import SwiftData

class GroupManager: ObservableObject {
    private let selectedGroupIdKey = "selectedGroupId"

    func saveSelectedGroup(_ group: ColorGroup?) {
        if let group = group {
            UserDefaults.standard.set(group.persistentModelID.hashValue, forKey: selectedGroupIdKey)
        } else {
            UserDefaults.standard.removeObject(forKey: selectedGroupIdKey)
        }
    }

    func getSelectedGroup(from groups: [ColorGroup]) -> ColorGroup? {
        let savedGroupHash = UserDefaults.standard.integer(forKey: selectedGroupIdKey)
        if savedGroupHash != 0 {
            return groups.first { $0.persistentModelID.hashValue == savedGroupHash }
        }
        return groups.first { $0.isDefault } ?? groups.first
    }
}