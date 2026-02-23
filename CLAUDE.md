# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Xpens is an iOS app for tracking business expenses while traveling or incurring costs. The core workflow is: capture receipts via OCR, categorize expenses, then export polished PDF/CSV reports to send to accounting. All data is stored locally on-device with optional iCloud backup. Built with Swift 6 / SwiftUI targeting iOS 18.0+ / Xcode 16+.

## Build & Run

The Xcode project is generated via [XcodeGen](https://github.com/yonaskolb/XcodeGen) from `Xpens/project.yml`. The `.xcodeproj` is gitignored — regenerate it after cloning or editing `project.yml`:

```
cd Xpens && xcodegen generate
```

### CLI commands (from `Xpens/` directory)

```bash
# Build
xcodebuild -project Xpens.xcodeproj -scheme Xpens \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Run all tests (94 tests: 82 unit + 12 UI)
xcodebuild -project Xpens.xcodeproj -scheme Xpens \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test

# Run only unit tests
xcodebuild -project Xpens.xcodeproj -scheme Xpens \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:XpensTests test

# Run only UI tests
xcodebuild -project Xpens.xcodeproj -scheme Xpens \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:XpensUITests test
```

Unit tests use Swift Testing framework (`import Testing`, `@Suite`, `@Test`, `#expect`). Test files are in `XpensTests/`. UI tests use XCUITest framework. Test files are in `XpensUITests/`. Centralized accessibility identifiers in `Utilities/AccessibilityID.swift` are shared between views and UI tests. Launch arguments `--uitesting-reset` and `--uitesting-skip-onboarding` control app state for UI tests.

## Architecture

### Data Layer
- **SwiftData** for persistence — models registered via `.modelContainer(for:)` at the app root:
  - `Expense` — core expense record with relationships to `Category` and `Tag`
  - `Category` — user-customizable categories with name, SF Symbol icon, hex color, and sort order. Ships with 8 defaults
  - `Tag` — freeform labels with name and hex color, many-to-many with Expense
  - `UserPreferences` — singleton for currency code, onboarding state, featured category IDs
- Receipt images stored as JPEGs in `Documents/Receipts/` with UUID filenames; the `Expense` model holds a relative path reference
- No backend — entirely local-first with optional iCloud backup

### Service Layer (`Services/`)
- **OCRService** — `@MainActor` singleton using Vision framework OCR with regex-based extraction of amounts, dates, and merchant names. Uses `@preconcurrency import Vision` for Swift 6 Sendable compliance. The extraction methods (`extractAmount`, `extractDate`, `extractMerchant`) are `internal` for testability
- **ImageStorageService** — JPEG storage/retrieval/deletion in the app's document directory (0.8 compression quality)
- **CSVExportService** — RFC 4180 compliant CSV with UTF-8 BOM for Excel compatibility. Includes Tags column
- **PDFExportService** — Multi-page PDF reports with category grouping, subtotals, tag breakdown, and page numbers
- **RecurringExpenseService** — Generates pending expenses from recurring templates (weekly/monthly/yearly) on app launch
- **BackupService** — iCloud Documents backup/restore of all data (expenses, categories, tags, preferences, receipt images) with timestamped `.xpensbackup` directories
- **TipJarService** — StoreKit 2 consumable tip products (coffee/lunch/dinner) with `@MainActor` ObservableObject

### UI Layer (`Views/`)
- Tab-based navigation: Expenses list, Add Expense, Reports, Settings
- State management: `@Query` for reactive SwiftData fetching, `@State`/`@Binding` for local UI state, `@Environment(\.modelContext)` for persistence operations
- Add expense flow: camera/photo library → OCR processing → pre-filled ManualEntryView, or direct manual entry
- Reusable components in `Views/Components/`: `CategoryPicker` (featured grid + searchable all-categories sheet), `CurrencyTextField`, `TagPicker`, `AllCategoriesSheet`
- **Charts** framework used in `ReportsView` for category breakdown visualization
- **Onboarding** — 3-page welcome flow (currency selection, featured categories) shown on first launch
- **Settings** — Currency picker, category/tag management, featured categories, iCloud backup/restore, tip jar

### Key Patterns
- `Category` is a SwiftData `@Model` with `name`, `icon` (SF Symbol), `color` (hex string), `sortOrder`, and `isDefault` flag
- `Color+Hex` extension converts hex strings to SwiftUI `Color`
- Services are `enum` namespaces with static methods (stateless), except `OCRService` (`@MainActor` singleton) and `TipJarService` (`@MainActor` ObservableObject)
- Async/await throughout for Vision framework, StoreKit, and image operations
- `CurrencyFormatter` is dynamic — configurable via `setCurrency(code:)`, initialized from `UserPreferences` on launch
- OCRService Vision continuation guards against double-resume with a `didResume` flag
- Recurring expenses use `Expense.isRecurring` flag with `recurrenceRule` string ("weekly"/"monthly"/"yearly")
- Creating a recurring expense also logs the first occurrence as a regular expense

## Roadmap

Planned features (see README.md for full list):
- App Store submission prep (icon, screenshots, description, privacy policy)
- Polish pass (empty states, haptics, dark mode audit)
- Performance profiling (SwiftData queries, PDF generation)
- Accessibility (VoiceOver, Dynamic Type, contrast)
- Home Screen Widget (WidgetKit)
- Search enhancements (amount range, date range, tag filters)
- Data visualization (trends, per-tag breakdowns, client reporting)
