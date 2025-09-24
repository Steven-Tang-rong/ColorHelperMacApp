//
//  MenuBarController.swift
//  ColorHelperMacApp
//
//  Created by Steven mini on 2025/9/15.
//

import SwiftUI
import SwiftData
import AppKit

class MenuBarController: ObservableObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var modelContext: ModelContext?

    init() {
        setupMenuBar()
    }

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let statusButton = statusItem?.button {
            statusButton.image = NSImage(systemSymbolName: "eyedropper", accessibilityDescription: "Color Helper")
            statusButton.action = #selector(statusBarButtonTapped)
            statusButton.target = self
            statusButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        print("MenuBarController: setupMenuBar")
        setupPopover()
    }

    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 280, height: 450)
        popover?.behavior = .transient
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        if let popover = popover {
            popover.contentViewController = NSHostingController(
                rootView: MenuBarPopoverView()
                    .modelContainer(context.container)
            )
        }
    }

    @objc private func statusBarButtonTapped() {
        guard let button = statusItem?.button else { return }

        let event = NSApp.currentEvent!

        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            togglePopover()
        }
    }

    private func togglePopover() {
        guard let popover = popover, let button = statusItem?.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    private func showContextMenu() {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "Open Main Window", action: #selector(openMainWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit ColorHelper", action: #selector(quit), keyEquivalent: "q"))

        menu.items.forEach { $0.target = self }
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    @objc private func openMainWindow() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        for window in NSApp.windows {
            if window.title == "ColorHelper" {
                window.makeKeyAndOrderFront(nil)
                return
            }
        }
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
