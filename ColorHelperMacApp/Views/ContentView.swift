//
//  ContentView.swift (Legacy)
//  ColorHelperMacApp
//
//  Created by Steven mini on 2025/9/15.
//  Note: This file is kept for reference but not used in the main app
//

import SwiftUI
import SwiftData

struct ContentView_Legacy: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [ColorItem]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Color \(item.hexCode)")
                    } label: {
                        Text(item.hexCode)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: addSampleItem) {
                        Label("Add Color", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select a color")
        }
    }

    private func addSampleItem() {
        withAnimation {
            let newItem = ColorItem(hexCode: "#FF0000")
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}
