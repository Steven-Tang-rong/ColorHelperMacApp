macOS Color Management Tool PRD
Version: 1.1
Date: 2025-09-15
Author: Steven58

1. Introduction
1.1 Product Overview
"ColorHelperMacApp" is a color management tool designed for macOS, combining a full-featured skeuomorphic main window with a convenient menu bar utility. Users can save colors via a global color eyedropper or by manually inputting color codes. The main window is responsible for displaying and managing all saved colors, while the menu bar utility provides quick access to the 10 most recently saved colors.

1.2 Problem Statement
Designers and developers frequently need to capture and manage color codes from various sources in their workflow. The traditional process is cumbersome and inefficient. Furthermore, many existing tools are either too simplistic, lacking management features, or too complex and not lightweight enough. This app aims to solve this problem through a dual-mode approach of "main window for management" + "menu bar for quick access".

1.3 Product Goals
Core Goal: To provide an integrated solution that allows for both rapid color picking and systematic management of a color library.

Secondary Goals:

The main window will adopt a refined skeuomorphic style to provide a pleasant visual experience.

The menu bar utility will ensure extreme performance and ease of use.

Utilize Swift Data to ensure modern, stable, and scalable data persistence.

The codebase will adhere to Clean Architecture and SOLID principles to facilitate long-term maintenance.

2. Target Audience
UI/UX Designers: Who need to create and manage color schemes for multiple projects.

Front-end/App Developers: Who need to accurately extract and manage color codes from design mockups.

Content Creators/Illustrators: Who need to conveniently pick and manage color palettes during their creative process.

3. Functional Requirements
A. Core Functionality
FR-1: Color Eyedropper
Description: Provides a global color eyedropper (magnifying glass tool) to pick the color of any pixel on the screen.

Trigger Points:

The "Pick Color" button within the main app window.

The "Pick Color" button within the menu bar popover.

Acceptance Criteria:

After clicking the button, the mouse cursor changes to the native system color picker.

After a left-click, the selected color is automatically saved to the Swift Data database.

Pressing the ESC key cancels the operation.

FR-2: Data Persistence with Swift Data
Description: All color data saved by the user will persist even after the app is closed or the computer is restarted.

User Story: "I want all my saved colors to be securely stored, no matter when I restart the app."

Technical Solution: Use the Swift Data framework to manage the color object model.

Feasibility: Swift Data is Apple's officially recommended persistence framework, deeply integrated with SwiftUI. It is highly suitable for this type of project and can easily handle data creation, retrieval, updating, and deletion (CRUD).

Acceptance Criteria:

After closing and relaunching the app, all saved colors should be fully loaded.

Color data should include the color code value (e.g., Hex) and a timestamp for sorting purposes.

B. Main Application Window
FR-3: Skeuomorphic UI
Description: The main window will adopt a skeuomorphic design style, simulating the texture of real-world objects like a swatch book, a paint box, or a toolbox.

User Story: "I hope this app is not only powerful but also looks like a beautifully crafted desktop tool, rather than a cold, generic window."

Acceptance Criteria:

Window background, buttons, color lists, and other elements should include skeuomorphic details such as shadows, textures, and highlights.

The interface style is consistent and aesthetically pleasing.

FR-4: Complete Color Library
Description: The main window displays all saved colors in a grid or list format.

User Story: "I want a single place where I can see all the colors I've saved, making it easy for me to organize and manage them."

Acceptance Criteria:

The interface can display more than 10 colors and provides a scroll view.

Each color item should display a color preview and its Hex code.

Clicking on any color item copies its code to the clipboard and provides visual feedback.

FR-5: Manual Color Input
Description: In the main window, provide an interface for users to manually type or paste a color code to save it.

User Story: "I want to be able to directly add a known color code to my library."

Acceptance Criteria:

The interface includes a text input field and an "Add" button.

The input field accepts standard Hex formats (#RRGGBB or RRGGBB).

After successful addition, the color appears in the color library.

C. Menu Bar Popover
FR-6: Menu Bar Presence and Quick Access
Description: The app icon resides in the system menu bar. Clicking the icon opens a lightweight popover interface.

User Story: "I want to be able to quickly access my recent colors without opening the main window."

Acceptance Criteria:

Clicking the menu bar icon shows the popover; clicking outside the popover dismisses it.

A right-click on the icon provides options like "Open Main Window," "About," and "Quit App."

FR-7: Recent Colors List
Description: The menu bar popover displays only the 10 most recently saved colors.

User Story: "When I need a color I used recently, I want to grab it directly from the menu bar instead of searching through my entire library."

Acceptance Criteria:

The interface displays a maximum of 10 colors in a list.

The list is sorted in reverse chronological order (newest on top).

Clicking any color item copies its code to the clipboard.

4. Non-Functional Requirements
Performance: The app should have a minimal CPU and memory footprint when running silently in the background. The interface should be smooth and responsive.

Compatibility: Supports macOS Sonoma (14.0) and above (to fully leverage the latest features of Swift Data and SwiftUI).

Architecture & Code Quality:

Clean Architecture: The code must follow a clear layered structure (e.g., Presentation, Domain, Data layers) to ensure separation of concerns and low coupling.

SOLID Principles: The development process must adhere to SOLID design principles (Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion) to enhance code readability, scalability, and maintainability.

5. User Flow
Quick Pick & Use:

User clicks the menu bar icon -> System displays the popover with 10 recent colors.

User clicks the "Pick Color" button -> User picks a color from the screen.

System saves the new color and updates it to the top of the popover list.

User clicks a color in the popover -> System copies the color code to the clipboard.

Manage Full Library:

User "Opens Main Window" from the Dock or the menu bar's right-click menu.

System displays the skeuomorphic main window containing all saved colors.

User manually adds a new color via the input field.

User browses and copies any color from the library.

6. Future Roadmap (v2.0)
Support for displaying and copying multiple color formats (RGB, HSL, Swift/CSS Code).

Customizable hotkeys to quickly launch the color eyedropper.

Create multiple palettes in the main window to categorize colors.

iCloud synchronization functionality.

Add custom names or tags to colors.
