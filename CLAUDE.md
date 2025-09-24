# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ColorHelperMacApp is a macOS SwiftUI application built with Xcode using SwiftData for persistence. The app appears to be in its initial state with a basic list-detail interface template.

## Architecture

- **App Entry Point**: `ColorHelperMacAppApp.swift` - Main app struct with SwiftData ModelContainer setup
- **Data Layer**: Uses SwiftData with `Item` model for persistence (currently a basic timestamp-based model)
- **UI Structure**: SwiftUI NavigationSplitView with master-detail layout in `ContentView.swift`
- **Testing**: Uses Swift Testing framework (not XCTest) - see the `@Test` annotations in test files

## Development Commands

### Building and Running
```bash
# Build the app
xcodebuild -scheme ColorHelperMacApp -project ColorHelperMacApp.xcodeproj build

# Build for specific configuration
xcodebuild -scheme ColorHelperMacApp -project ColorHelperMacApp.xcodeproj -configuration Debug build
xcodebuild -scheme ColorHelperMacApp -project ColorHelperMacApp.xcodeproj -configuration Release build
```

### Testing
```bash
# Run all tests
xcodebuild test -scheme ColorHelperMacApp -project ColorHelperMacApp.xcodeproj

# Run specific test target
xcodebuild test -scheme ColorHelperMacApp -project ColorHelperMacApp.xcodeproj -only-testing:ColorHelperMacAppTests
xcodebuild test -scheme ColorHelperMacApp -project ColorHelperMacApp.xcodeproj -only-testing:ColorHelperMacAppUITests
```

## Key Technical Details

- **Swift Testing**: Project uses the new Swift Testing framework, not XCTest
- **SwiftData**: Configured with persistent storage (not in-memory) in the main app
- **Sandboxing**: App is sandboxed with read-only file access permissions
- **Target Support**: Single macOS target with unit and UI test targets

## File Structure
- `ColorHelperMacApp/` - Main app source code
- `ColorHelperMacAppTests/` - Unit tests
- `ColorHelperMacAppUITests/` - UI tests
- `ColorHelperMacApp.xcodeproj/` - Xcode project file