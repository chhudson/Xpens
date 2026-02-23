# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Slide3 Expenses is an iOS app built for Slide3 employees to track business expenses while traveling or incurring costs. The core workflow is: capture receipts via OCR, categorize expenses, then export polished PDF/CSV reports to send to accounting. All data is stored locally on-device — the app focuses on making the capture-to-export loop as frictionless as possible. Built with Swift/SwiftUI targeting iOS 18.0+ / Xcode 15+.

## Build & Run

The Xcode project is generated via [XcodeGen](https://github.com/yonaskolb/XcodeGen) from `Slide3Expenses/project.yml`. After editing `project.yml`, regenerate with:

```
cd Slide3Expenses && xcodegen generate
```

### CLI commands (from `Slide3Expenses/` directory)

```bash
# Build
xcodebuild -project Slide3Expenses.xcodeproj -scheme Slide3Expenses \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Run all tests
xcodebuild -project Slide3Expenses.xcodeproj -scheme Slide3Expenses \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

Tests use Swift Testing framework (`import Testing`, `@Suite`, `@Test`, `#expect`). Test files are in `Slide3ExpensesTests/`.

## Architecture

### Data Layer
- **SwiftData** for persistence — the `Expense` model uses `@Model` macro and is registered via `.modelContainer(for: Expense.self)` at the app root
- Receipt images stored as JPEGs in `Documents/Receipts/` with UUID filenames; the `Expense` model holds a relative path reference
- No backend or network layer — entirely local-first

### Service Layer (`Services/`)
- **OCRService** — Vision framework OCR with regex-based extraction of amounts, dates, and merchant names from receipt text
- **ImageStorageService** — JPEG storage/retrieval/deletion in the app's document directory
- **CSVExportService** — RFC 4180 compliant CSV with UTF-8 BOM for Excel compatibility
- **PDFExportService** — Multi-page PDF reports with category grouping, subtotals, and page numbers

### UI Layer (`Views/`)
- Tab-based navigation: Expenses list, Add Expense, Reports
- State management: `@Query` for reactive SwiftData fetching, `@State`/`@Binding` for local UI state, `@Environment(\.modelContext)` for persistence operations
- Add expense flow: camera/photo library → OCR processing → pre-filled ManualEntryView, or direct manual entry
- Reusable components in `Views/Components/`: `CategoryPicker` (2-column grid), `CurrencyTextField` (formatted decimal input)

### Key Patterns
- `ExpenseCategory` enum has four cases (`airlineTickets`, `hotel`, `rideshare`, `food`) each with `displayName`, `icon` (SF Symbol), and `color`
- Category is stored as a raw string in SwiftData (`categoryRawValue`) with a computed property wrapper for type-safe access
- OCRService uses `@MainActor` singleton pattern
- Async/await throughout for Vision framework and image operations
- `CurrencyFormatter` handles USD formatting and parsing with a static API
