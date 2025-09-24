# ColorHelperMacApp Architecture

## 🏗️ System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         macOS Application                       │
├─────────────────────────────────────────────────────────────────┤
│                          App Layer                              │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                ColorHelperMacAppApp                     │    │
│  │  • SwiftUI App Entry Point                              │    │
│  │  • AppDelegate (NSApplicationDelegate)                  │    │
│  │  • ModelContainer Setup                                 │    │
│  │  • Window Management                                    │    │
│  └─────────────────────────────────────────────────────────┘    │
├─────────────────────────────────────────────────────────────────┤
│                        Presentation Layer                       │
│  ┌──────────────────┐  ┌──────────────────┐  ┌─────────────┐    │
│  │   MainWindowView │  │ MenuBarPopoverView│  │SideMenuView │    │
│  │  • Color Grid    │  │  • Recent Colors  │  │• Group List │    │
│  │  • Manual Input  │  │  • Quick Access   │  │• All Colors │    │
│  │  • Color Details │  │  • Group Selector │  │• Management │    │
│  │  • Eyedropper    │  │  • Copy Actions   │  │• CRUD Ops   │    │
│  └──────────────────┘  └──────────────────┘  └─────────────┘    │
├─────────────────────────────────────────────────────────────────┤
│                        Controller Layer                         │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                 MenuBarController                       │    │
│  │  • NSStatusItem Management                              │    │
│  │  • NSPopover Coordination                               │    │
│  │  • Menu Bar Lifecycle                                   │    │
│  │  • System Integration                                   │    │
│  └─────────────────────────────────────────────────────────┘    │
├─────────────────────────────────────────────────────────────────┤
│                        Service Layer                            │
│  ┌──────────────────┐         ┌──────────────────────────┐      │
│  │ColorPickerService│         │      GroupManager        │      │
│  │ • Global Picking │         │ • Selection Persistence │      │
│  │ • NSColorSampler │         │ • UserDefaults Storage  │      │
│  │ • Color Creation │         │ • Group State Management│      │
│  │ • Context Binding│         │ • Cross-View Sync       │      │
│  └──────────────────┘         └──────────────────────────┘      │
├─────────────────────────────────────────────────────────────────┤
│                         Data Layer                              │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    SwiftData Models                     │    │
│  │  ┌─────────────────┐      ┌─────────────────────────┐   │    │
│  │  │   ColorItem     │      │      ColorGroup        │   │    │
│  │  │ • hexCode       │◄────►│ • name                 │   │    │
│  │  │ • timestamp     │      │ • createdAt            │   │    │
│  │  │ • red/green/blue│      │ • isDefault            │   │    │
│  │  │ • group         │      │ • colorItems[]         │   │    │
│  │  └─────────────────┘      └─────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────────┘    │
├─────────────────────────────────────────────────────────────────┤
│                       Persistence Layer                         │
│  ┌──────────────────┐         ┌──────────────────────────┐      │
│  │   SwiftData      │         │      UserDefaults        │      │
│  │ • ModelContainer │         │ • selectedGroupId       │      │
│  │ • ModelContext   │         │ • App Preferences       │      │
│  │ • Automatic CRUD │         │ • Session Persistence   │      │
│  │ • Relationships  │         │ • Cross-Launch State    │      │
│  └──────────────────┘         └──────────────────────────┘      │
└─────────────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow Diagram

```
                    User Interactions
                          │
                          ▼
    ┌─────────────────────────────────────────────────────────┐
    │                  View Layer                             │
    │  MainWindowView ◄──► MenuBarPopoverView ◄──► SideMenuView │
    └─────────────────────────────────────────────────────────┘
                          │
                          ▼
    ┌─────────────────────────────────────────────────────────┐
    │                Service Layer                            │
    │   ColorPickerService   ◄────►   GroupManager           │
    └─────────────────────────────────────────────────────────┘
                          │
                          ▼
    ┌─────────────────────────────────────────────────────────┐
    │                 Data Models                             │
    │      ColorItem   ◄────1:N────►   ColorGroup            │
    └─────────────────────────────────────────────────────────┘
                          │
                          ▼
    ┌─────────────────────────────────────────────────────────┐
    │              Persistence Layer                          │
    │    SwiftData ModelContainer  ◄──►  UserDefaults        │
    └─────────────────────────────────────────────────────────┘
```

## 📁 File Organization

### `/App` - Application Lifecycle
```
App/
└── ColorHelperMacAppApp.swift
    ├── @main App Entry Point
    ├── AppDelegate (NSApplicationDelegate)
    ├── ModelContainer Configuration
    ├── Window Management
    └── Menu Bar Initialization
```

### `/Models` - Data Layer
```
Models/
├── ColorItem.swift
│   ├── @Model SwiftData Entity
│   ├── Color Properties (hex, rgb)
│   ├── Timestamp for Sorting
│   ├── Group Relationship
│   └── SwiftUI Color Conversion
└── ColorGroup.swift
    ├── @Model SwiftData Entity
    ├── Group Metadata (name, date)
    ├── Default Group Flag
    ├── @Relationship with ColorItems
    └── Computed Properties (count)
```

### `/Views` - Presentation Layer
```
Views/
├── MainWindowView.swift
│   ├── Primary Application Interface
│   ├── Color Grid Display
│   ├── Manual Color Input
│   ├── Color Details Panel
│   ├── Eyedropper Integration
│   └── Side Menu Integration
├── MenuBarPopoverView.swift
│   ├── Menu Bar Quick Access
│   ├── Recent Colors Display
│   ├── Group Selection Dropdown
│   ├── Copy to Clipboard
│   └── Main Window Launcher
├── SideMenuView.swift
│   ├── Group Management Interface
│   ├── "All Colors" Option
│   ├── Group CRUD Operations
│   ├── Selection State Management
│   └── Group Statistics Display
└── ContentView.swift
    └── Initial Template (Unused)
```

### `/Controllers` - System Integration
```
Controllers/
└── MenuBarController.swift
    ├── NSStatusItem Management
    ├── NSPopover Lifecycle
    ├── Menu Bar Appearance
    ├── Global Event Handling
    └── Model Context Integration
```

### `/Services` - Business Logic
```
Services/
├── ColorPickerService.swift
│   ├── @StateObject Observable Service
│   ├── NSColorSampler Integration
│   ├── Global Color Picking
│   ├── Model Context Management
│   ├── Current Group Binding
│   └── Color Creation & Persistence
└── GroupManager.swift
    ├── @StateObject Observable Service
    ├── Group Selection Persistence
    ├── UserDefaults Integration
    ├── Cross-View State Sync
    └── Selection Restoration
```

## 🔗 Component Relationships

### Data Relationships
- **ColorGroup** → **ColorItem** (1:N relationship)
- **ColorItem** → **ColorGroup** (N:1 relationship)
- Cascade delete: Deleting group removes all colors

### View Dependencies
- **MainWindowView** uses **SideMenuView** for group management
- **SideMenuView** manages **selectedGroup** binding
- **MenuBarPopoverView** displays group-filtered colors
- All views share the same **ModelContext** from SwiftData

### Service Integration
- **ColorPickerService** creates colors in the current group
- **GroupManager** persists group selection across app launches
- Both services are **@StateObject** for lifecycle management

### State Management
- **@Query** for automatic SwiftData updates
- **@Binding** for parent-child view communication
- **@StateObject** for service lifecycle management
- **UserDefaults** for persistent app preferences

## 🎯 Key Architectural Patterns

### 1. **MVVM with SwiftUI**
- Views observe **@StateObject** services
- Business logic separated into service layer
- Data binding through **@Query** and **@Binding**

### 2. **Repository Pattern**
- SwiftData acts as repository abstraction
- Models encapsulate data logic
- Services handle business operations

### 3. **Observer Pattern**
- SwiftData **@Query** for automatic UI updates
- **@StateObject** services for cross-view communication
- **UserDefaults** for preference persistence

### 4. **Dependency Injection**
- **ModelContext** injected through environment
- Services injected as **@StateObject**
- Shared state through bindings

## 🚀 Application Flow

### Startup Sequence
1. **App Launch** → ColorHelperMacAppApp initializes
2. **Model Setup** → SwiftData container configured
3. **Window Creation** → MainWindowView displayed
4. **Menu Bar Setup** → MenuBarController initializes NSStatusItem
5. **Default Data** → Default group created if needed
6. **State Restoration** → Previous group selection restored

### User Interaction Flow
1. **Color Picking** → ColorPickerService triggers NSColorSampler
2. **Color Creation** → New ColorItem saved to current group
3. **UI Updates** → @Query automatically refreshes all views
4. **Group Selection** → State synced across main window and menu bar
5. **Persistence** → Selection saved to UserDefaults

### Data Persistence
1. **SwiftData** → Automatic persistence of models
2. **UserDefaults** → Group selection and preferences
3. **Cross-Launch** → State restoration on app restart

---

*Generated on: 2025-09-22*
*Project: ColorHelperMacApp*
*Architecture: SwiftUI + SwiftData + MVVM*