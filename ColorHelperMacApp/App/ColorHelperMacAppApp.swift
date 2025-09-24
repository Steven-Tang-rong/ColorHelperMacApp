//
//  ColorHelperMacAppApp.swift
//  ColorHelperMacApp
//
//  Created by Steven mini on 2025/9/15.
//

import SwiftUI
import SwiftData

@main
struct ColorHelperMacAppApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ColorItem.self,
            ColorGroup.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup("ColorHelper") {
            MainWindowView()
                .background(Color(NSColor.windowBackgroundColor))
        }
        .modelContainer(sharedModelContainer)
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unifiedCompact)
        .defaultSize(width: 820, height: 600)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set the app as accessory (menu bar only)
        NSApp.setActivationPolicy(.accessory)

        // Initialize menu bar controller
        menuBarController = MenuBarController()

        // Set up model context for menu bar
        let schema = Schema([ColorItem.self, ColorGroup.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let context = ModelContext(container)
            menuBarController?.setModelContext(context)
        } catch {
            print("Failed to create model container: \(error)")
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // No windows are visible, so show the main window
            for window in sender.windows {
                if window.title == "ColorHelper" {
                    window.makeKeyAndOrderFront(nil)
                    NSApp.setActivationPolicy(.regular)
                    NSApp.activate(ignoringOtherApps: true)
                    return false
                }
            }
        }
        return true
    }
}
