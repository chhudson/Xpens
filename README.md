# Slide3 Expenses

An iOS app for tracking business expenses with receipt OCR scanning. Built for Slide3 employees to capture, categorize, and export expenses while traveling — but useful for anyone managing receipts and expense reports.

## Features

- **Receipt OCR** — Scan receipts with your camera or photo library. The Vision framework automatically extracts amounts, dates, and merchant names
- **Expense Categories** — Organize expenses as Airline Tickets, Hotel, Rideshare, or Food
- **Search & Filter** — Find expenses by merchant, client, category, or date range
- **PDF Reports** — Generate professional multi-page expense reports grouped by category with subtotals
- **CSV Export** — Export to spreadsheet-compatible CSV (RFC 4180, UTF-8 BOM for Excel)
- **Local-First** — All data stays on your device. No accounts, no cloud sync, no backend

## Requirements

- iOS 18.0+
- Xcode 16+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

## Getting Started

```bash
# Clone the repo
git clone git@github.com:chhudson/Slide3Expenses.git
cd Slide3Expenses

# Generate the Xcode project
cd Slide3Expenses && xcodegen generate

# Open in Xcode
open Slide3Expenses.xcodeproj
```

Build and run on a simulator or device (Cmd+R).

## Running Tests

```bash
# From the Slide3Expenses/ directory
xcodebuild -project Slide3Expenses.xcodeproj -scheme Slide3Expenses \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

57 unit tests cover models, services, and utilities using the Swift Testing framework.

## Project Structure

```
Slide3Expenses/
├── project.yml                  # XcodeGen spec (source of truth for project config)
├── Slide3Expenses/              # App source
│   ├── Models/                  # Expense, ExpenseCategory, OCRResult
│   ├── Services/                # OCR, image storage, CSV/PDF export
│   ├── Views/                   # SwiftUI views organized by feature
│   ├── Utilities/               # CurrencyFormatter, Date extensions
│   └── Assets.xcassets/
└── Slide3ExpensesTests/         # Unit tests (Swift Testing)
```

## Tech Stack

- **Swift 6** / **SwiftUI** — UI and app architecture
- **SwiftData** — On-device persistence
- **Vision** — Receipt text recognition (OCR)
- **Charts** — Expense category visualizations
- **XcodeGen** — Xcode project generation from YAML
