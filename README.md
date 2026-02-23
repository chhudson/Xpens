# Xpens

An iOS app for tracking business expenses with receipt OCR scanning. Capture, categorize, tag, and export expenses — useful for anyone managing receipts and expense reports.

## Features

- **Receipt OCR** — Scan receipts with your camera or photo library. The Vision framework automatically extracts amounts, dates, and merchant names
- **Custom Categories** — Create and manage your own expense categories with icons and colors. Ships with 8 defaults (Airline Tickets, Hotel, Rideshare, Food, Office Supplies, Parking, Entertainment, Misc)
- **Tags** — Add freeform tags to expenses for flexible organization (e.g., "tax-deductible", "Q1-2026")
- **Recurring Expenses** — Set up weekly, monthly, or yearly recurring expenses that auto-generate on app launch
- **Search & Filter** — Find expenses by merchant, client, category, tag, or date range
- **PDF Reports** — Generate professional multi-page expense reports grouped by category with subtotals and tag breakdowns
- **CSV Export** — Export to spreadsheet-compatible CSV (RFC 4180, UTF-8 BOM for Excel)
- **Configurable Currency** — Choose from any ISO 4217 currency, with 20 popular currencies featured
- **iCloud Backup** — Back up and restore all data (expenses, categories, tags, receipts) via iCloud Documents
- **Tip Jar** — Support development with optional in-app tips via StoreKit 2
- **Local-First** — All data stays on your device. No accounts required

## Requirements

- iOS 18.0+
- Xcode 16+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

## Getting Started

```bash
# Clone the repo
git clone git@github.com:chhudson/Xpens.git
cd Xpens

# Generate the Xcode project
cd Xpens && xcodegen generate

# Open in Xcode
open Xpens.xcodeproj
```

Build and run on a simulator or device (Cmd+R). On first launch, the onboarding flow will guide you through currency selection and featured category setup.

## Running Tests

```bash
# From the Xpens/ directory
xcodebuild -project Xpens.xcodeproj -scheme Xpens \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

94 tests total:
- **82 unit tests** across 14 suites (Swift Testing framework) — models, services, utilities
- **12 UI tests** across 5 suites (XCUITest) — onboarding, expense entry, recurring, reports, settings

## Project Structure

```
Xpens/
├── project.yml                  # XcodeGen spec (source of truth for project config)
├── Xpens/                       # App source
│   ├── Models/                  # Expense, Category, Tag, UserPreferences, OCRResult
│   ├── Services/                # OCR, image storage, CSV/PDF export, recurring, backup, tip jar
│   ├── Views/                   # SwiftUI views organized by feature
│   │   ├── AddExpense/          # Camera/manual entry flows
│   │   ├── Components/          # CategoryPicker, TagPicker, CurrencyTextField
│   │   ├── ExpenseDetail/       # Detail/edit views
│   │   ├── ExpenseList/         # List, row, filter, recurring row
│   │   ├── Onboarding/          # First-launch welcome flow
│   │   ├── Reports/             # Charts, PDF/CSV export
│   │   └── Settings/            # Currency, categories, tags, backup, tip jar
│   ├── Utilities/               # CurrencyFormatter, Color+Hex, Date extensions
│   ├── Configuration.storekit   # StoreKit testing configuration
│   └── Assets.xcassets/
└── XpensTests/                  # Unit tests (Swift Testing)
```

## Tech Stack

- **Swift 6** / **SwiftUI** — UI and app architecture
- **SwiftData** — On-device persistence with model relationships
- **Vision** — Receipt text recognition (OCR)
- **Charts** — Expense category visualizations
- **StoreKit 2** — In-app tip jar purchases
- **CloudKit** — iCloud Documents backup container
- **XcodeGen** — Xcode project generation from YAML

## Roadmap

- [ ] **App Store submission** — App icon, screenshots, App Store description, privacy policy
- [ ] **Polish pass** — Empty state refinements, error handling edge cases, haptic feedback, loading indicators, dark mode audit
- [ ] **Performance profiling** — Instruments profiling for SwiftData queries on large datasets and PDF generation
- [ ] **Accessibility** — VoiceOver labels, Dynamic Type support, color contrast audit
- [ ] **Home Screen Widget** — WidgetKit widget showing recent expenses or monthly total
- [ ] **Search enhancements** — Filter by amount range, date range, and tags from the search bar
- [ ] **Data visualization** — Monthly spending trends, per-tag breakdowns, client-level reporting
