# Xpens v1 Product Design

## Overview

Rebrand Slide3 Expenses into **Xpens** — a generic, local-first iOS expense tracker for the App Store. Target user: individuals and employees at small companies who need to track business expenses, scan receipts, and export reports. Free with optional tip jar. No accounts, no cloud sync, no team features.

## Rebrand

- Slide3 Expenses → **Xpens**
- New bundle ID (e.g. `com.xpens.app`)
- Remove all Slide3 references from PDF report titles, CSV/PDF file prefixes, README, CLAUDE.md
- New app icon (TBD)

## Data Model Changes

### Categories (user-defined, replaces hardcoded enum)

New `Category` SwiftData model:
- `id: UUID`
- `name: String`
- `icon: String` (SF Symbol name)
- `color: String` (hex)
- `sortOrder: Int`
- `isDefault: Bool`

Replaces `ExpenseCategory` enum. `Expense.categoryRawValue` becomes a SwiftData relationship to `Category`.

Default categories shipped with app (~8): Airline Tickets, Hotel, Rideshare, Food, Office Supplies, Parking, Entertainment, Misc.

User can CRUD categories in Settings. Deleting a category with existing expenses prompts reassignment to another category.

### Featured Categories

User picks 4 categories to display in the quick-pick grid. Stored as an ordered list of category IDs in user preferences. An "Other" option opens the full category list.

### Tags

New `Tag` SwiftData model:
- `id: UUID`
- `name: String`
- `color: String` (hex)

Many-to-many relationship with `Expense`. No presets — user creates tags (e.g. "tax-deductible", "reimbursable", "Q1 trip"). Tags are optional.

### Currency

- User-configurable default currency stored as ISO 4217 code (e.g. "USD", "EUR", "GBP")
- `CurrencyFormatter` becomes dynamic based on selected currency
- One currency per app, not per expense

### Recurring Expenses

New fields on `Expense`:
- `isRecurring: Bool`
- `recurrenceRule: String?` — encoded as "weekly", "monthly", or "yearly"

A recurring expense is a template. The app auto-generates actual expense entries on launch for any pending intervals since last open.

## UI Changes

### Onboarding (new, first launch only)

3 screens, skippable:
1. Welcome / value prop
2. Pick default currency
3. Pick 4 featured categories

### Settings Screen (new)

- Default currency picker
- Manage Categories (full CRUD list)
- Manage Featured Categories (pick 4)
- Manage Tags (CRUD)
- Tip Jar
- Backup to iCloud / Restore from iCloud
- About / version

### Category Picker (redesigned)

- Top: 2x2 grid of 4 featured categories (same visual style as current)
- Below: "Other" button → sheet with full searchable category list

### Expense List (enhanced)

- Filter by tag (in addition to category and client)
- Tag pills displayed on ExpenseRowView

### Reports (enhanced)

- Tag-based filtering alongside category/client/date
- Tags included in CSV as comma-separated column
- PDF reports include tag breakdown section

### Recurring Expenses (new)

- Section in Expenses tab showing active recurring templates
- Shows: category, amount, merchant, frequency, next date
- Auto-generates pending entries on app launch
- "Add Recurring" reuses ManualEntryView with frequency picker

## iCloud Backup/Restore

Manual, not sync. Safety net for device changes.

**Backup:**
- Settings > "Back Up to iCloud"
- Archives all SwiftData models + receipt images to app's iCloud Documents container
- Timestamped backups, user can keep several
- Shows size estimate before starting

**Restore:**
- Settings > "Restore from iCloud"
- Lists backups by date and expense count
- Full replace of local data (with confirmation)
- No partial merge

## Tip Jar

StoreKit 2, three one-time IAP tiers:
- "Buy me a coffee" — $1.99
- "Buy me lunch" — $4.99
- "Buy me dinner" — $9.99

Section in Settings with friendly copy. No feature unlocks.

## Explicitly Out of Scope

- User accounts / authentication
- Cloud sync / multi-device
- Team features / approval workflows
- Per-expense currency or conversion
- Budgets / spending alerts
- Widgets / Apple Watch / Shortcuts
- Multiple expense profiles
