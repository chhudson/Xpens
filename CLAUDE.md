# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Xpens is an iOS app for tracking business expenses while traveling or incurring costs. The core workflow is: capture receipts via OCR, categorize expenses, then export polished PDF/CSV reports to send to accounting. All data is stored locally on-device — the app focuses on making the capture-to-export loop as frictionless as possible. Built with Swift 6 / SwiftUI targeting iOS 18.0+ / Xcode 16+.

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

# Run all tests (57 tests across 11 suites)
xcodebuild -project Xpens.xcodeproj -scheme Xpens \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

Tests use Swift Testing framework (`import Testing`, `@Suite`, `@Test`, `#expect`). Test files are in `XpensTests/`.

## Architecture

### Data Layer
- **SwiftData** for persistence — the `Expense` model uses `@Model` macro and is registered via `.modelContainer(for: Expense.self)` at the app root
- Receipt images stored as JPEGs in `Documents/Receipts/` with UUID filenames; the `Expense` model holds a relative path reference
- No backend or network layer — entirely local-first

### Service Layer (`Services/`)
- **OCRService** — `@MainActor` singleton using Vision framework OCR with regex-based extraction of amounts, dates, and merchant names. Uses `@preconcurrency import Vision` for Swift 6 Sendable compliance. The extraction methods (`extractAmount`, `extractDate`, `extractMerchant`) are `internal` for testability
- **ImageStorageService** — JPEG storage/retrieval/deletion in the app's document directory (0.8 compression quality)
- **CSVExportService** — RFC 4180 compliant CSV with UTF-8 BOM for Excel compatibility
- **PDFExportService** — Multi-page PDF reports with category grouping, subtotals, and page numbers

### UI Layer (`Views/`)
- Tab-based navigation: Expenses list, Add Expense, Reports
- State management: `@Query` for reactive SwiftData fetching, `@State`/`@Binding` for local UI state, `@Environment(\.modelContext)` for persistence operations
- Add expense flow: camera/photo library → OCR processing → pre-filled ManualEntryView, or direct manual entry
- Reusable components in `Views/Components/`: `CategoryPicker` (2-column grid), `CurrencyTextField` (formatted decimal input with 2-decimal display)
- **Charts** framework used in `ReportsView` for category breakdown visualization

### Key Patterns
- `ExpenseCategory` enum has four cases (`airlineTickets`, `hotel`, `rideshare`, `food`) each with `displayName`, `icon` (SF Symbol), and `color`
- Category is stored as a raw string in SwiftData (`categoryRawValue`) with a computed property wrapper for type-safe access
- Async/await throughout for Vision framework and image operations
- `CurrencyFormatter` handles USD formatting and parsing with a static API
- OCRService Vision continuation guards against double-resume with a `didResume` flag
