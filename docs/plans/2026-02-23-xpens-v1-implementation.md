# Xpens v1 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform Slide3 Expenses into Xpens — a generic, local-first App Store expense tracker with custom categories, tags, configurable currency, recurring expenses, iCloud backup, and tip jar.

**Architecture:** SwiftData models for Category, Tag, and UserPreferences replace the hardcoded ExpenseCategory enum. Expense gains relationships to Category and Tag. A new Settings tab hosts all configuration. CurrencyFormatter becomes dynamic. Recurring expenses are templates that auto-generate entries on app launch.

**Tech Stack:** Swift 6, SwiftUI, SwiftData, Vision, Charts, StoreKit 2, CloudKit (iCloud Documents container)

---

## Phase 1: Rebrand (Slide3 → Xpens)

### Task 1: Rename project structure and configuration

**Files:**
- Modify: `Slide3Expenses/project.yml`
- Modify: `CLAUDE.md`
- Modify: `README.md`

**Step 1: Update project.yml**

Replace all Slide3 references:
- `name: Slide3Expenses` → `name: Xpens`
- `bundleIdPrefix: com.slide3` → `bundleIdPrefix: com.xpens`
- Target `Slide3Expenses` → `Xpens`
- Target `Slide3ExpensesTests` → `XpensTests`
- `PRODUCT_BUNDLE_IDENTIFIER: com.slide3.expenses` → `com.xpens.app`
- `PRODUCT_BUNDLE_IDENTIFIER: com.slide3.expenses.tests` → `com.xpens.app.tests`
- Update `TEST_HOST` and `BUNDLE_LOADER` to reference `Xpens.app` and `Xpens`

**Step 2: Rename source directories**

```bash
mv Slide3Expenses/Slide3Expenses Slide3Expenses/Xpens
mv Slide3Expenses/Slide3ExpensesTests Slide3Expenses/XpensTests
```

Update `project.yml` source paths:
- `sources: Xpens` (app target)
- `sources: XpensTests` (test target)

**Step 3: Rename app entry point**

Rename `Slide3ExpensesApp.swift` → `XpensApp.swift`. Change struct name:

```swift
@main
struct XpensApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: Expense.self)
    }
}
```

**Step 4: Update all `@testable import` statements**

In every test file, change `@testable import Slide3Expenses` → `@testable import Xpens`.

**Step 5: Regenerate and verify**

```bash
cd Slide3Expenses && xcodegen generate
xcodebuild -project Xpens.xcodeproj -scheme Xpens \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

All 57 tests must pass.

**Step 6: Rename top-level directory**

```bash
cd .. && mv Slide3Expenses Xpens
```

Update `project.yml` path references and CLI commands in CLAUDE.md and README.md accordingly.

**Step 7: Commit**

```bash
git add -A && git commit -m "Rebrand Slide3 Expenses to Xpens"
```

---

### Task 2: Remove Slide3 branding from exports

**Files:**
- Modify: `Xpens/Xpens/Services/PDFExportService.swift`
- Modify: `Xpens/Xpens/Services/CSVExportService.swift`

**Step 1: Update PDF title and file prefix**

In `PDFExportService.swift`:
- `"Slide3 Expense Report"` → `"Expense Report"`
- `"Slide3_Report_\(fileTimestamp()).pdf"` → `"Xpens_Report_\(fileTimestamp()).pdf"`

**Step 2: Update CSV file prefix**

In `CSVExportService.swift`:
- `"Slide3_Expenses_\(fileTimestamp()).csv"` → `"Xpens_Expenses_\(fileTimestamp()).csv"`

**Step 3: Update existing PDF tests**

In `PDFExportServiceTests.swift`:
- `"Slide3_Report"` → `"Xpens_Report"` in the filename assertion

**Step 4: Run tests, verify pass**

```bash
xcodebuild ... test
```

**Step 5: Commit**

```bash
git add -A && git commit -m "Remove Slide3 branding from PDF/CSV exports"
```

---

## Phase 2: New Data Models

### Task 3: Create Category SwiftData model

**Files:**
- Create: `Xpens/Xpens/Models/Category.swift`
- Create: `Xpens/XpensTests/CategoryModelTests.swift`

**Step 1: Write failing tests for Category model**

```swift
import Foundation
import Testing
@testable import Xpens

@Suite("Category Model")
struct CategoryModelTests {

    @Test("initializes with all required fields")
    func initFields() {
        let cat = Category(name: "Food", icon: "fork.knife", color: "#4CAF50", sortOrder: 0)
        #expect(cat.name == "Food")
        #expect(cat.icon == "fork.knife")
        #expect(cat.color == "#4CAF50")
        #expect(cat.sortOrder == 0)
        #expect(cat.isDefault == false)
    }

    @Test("default categories factory creates 8 categories")
    func defaultCategories() {
        let defaults = Category.createDefaults()
        #expect(defaults.count == 8)
        #expect(defaults.allSatisfy { $0.isDefault })
    }

    @Test("swiftUIColor converts hex to Color")
    func hexToColor() {
        let cat = Category(name: "Test", icon: "star", color: "#FF0000", sortOrder: 0)
        // Just verify it doesn't crash — Color equality is unreliable
        let _ = cat.swiftUIColor
    }
}
```

**Step 2: Run tests to verify they fail**

**Step 3: Implement Category model**

```swift
import Foundation
import SwiftData
import SwiftUI

@Model
final class Category {
    var id: UUID
    var name: String
    var icon: String
    var color: String  // hex, e.g. "#4CAF50"
    var sortOrder: Int
    var isDefault: Bool

    @Relationship(inverse: \Expense.category) var expenses: [Expense]?

    var swiftUIColor: Color {
        Color(hex: color)
    }

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        color: String,
        sortOrder: Int,
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.sortOrder = sortOrder
        self.isDefault = isDefault
    }

    static func createDefaults() -> [Category] {
        [
            Category(name: "Airline Tickets", icon: "airplane", color: "#2196F3", sortOrder: 0, isDefault: true),
            Category(name: "Hotel", icon: "building.2", color: "#9C27B0", sortOrder: 1, isDefault: true),
            Category(name: "Rideshare", icon: "car", color: "#FF9800", sortOrder: 2, isDefault: true),
            Category(name: "Food", icon: "fork.knife", color: "#4CAF50", sortOrder: 3, isDefault: true),
            Category(name: "Office Supplies", icon: "pencil.and.ruler", color: "#607D8B", sortOrder: 4, isDefault: true),
            Category(name: "Parking", icon: "parkingsign", color: "#795548", sortOrder: 5, isDefault: true),
            Category(name: "Entertainment", icon: "film", color: "#E91E63", sortOrder: 6, isDefault: true),
            Category(name: "Misc", icon: "ellipsis.circle", color: "#9E9E9E", sortOrder: 7, isDefault: true),
        ]
    }
}
```

**Step 4: Add Color hex extension**

Create `Xpens/Xpens/Utilities/Color+Hex.swift`:

```swift
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        self.init(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
}
```

**Step 5: Run tests, verify pass**

**Step 6: Commit**

```bash
git commit -m "Add Category SwiftData model with defaults and hex color support"
```

---

### Task 4: Create Tag SwiftData model

**Files:**
- Create: `Xpens/Xpens/Models/Tag.swift`
- Create: `Xpens/XpensTests/TagModelTests.swift`

**Step 1: Write failing tests**

```swift
import Foundation
import Testing
@testable import Xpens

@Suite("Tag Model")
struct TagModelTests {

    @Test("initializes with name and color")
    func initFields() {
        let tag = Tag(name: "tax-deductible", color: "#4CAF50")
        #expect(tag.name == "tax-deductible")
        #expect(tag.color == "#4CAF50")
    }
}
```

**Step 2: Implement Tag model**

```swift
import Foundation
import SwiftData
import SwiftUI

@Model
final class Tag {
    var id: UUID
    var name: String
    var color: String

    var expenses: [Expense]?

    var swiftUIColor: Color {
        Color(hex: color)
    }

    init(id: UUID = UUID(), name: String, color: String) {
        self.id = id
        self.name = name
        self.color = color
    }
}
```

**Step 3: Run tests, verify pass, commit**

---

### Task 5: Create UserPreferences model

**Files:**
- Create: `Xpens/Xpens/Models/UserPreferences.swift`
- Create: `Xpens/XpensTests/UserPreferencesTests.swift`

**Step 1: Write failing tests**

```swift
import Foundation
import Testing
@testable import Xpens

@Suite("UserPreferences")
struct UserPreferencesTests {

    @Test("defaults to USD currency")
    func defaultCurrency() {
        let prefs = UserPreferences()
        #expect(prefs.currencyCode == "USD")
    }

    @Test("defaults to not onboarded")
    func defaultOnboarding() {
        let prefs = UserPreferences()
        #expect(prefs.hasCompletedOnboarding == false)
    }

    @Test("stores featured category IDs")
    func featuredCategories() {
        let prefs = UserPreferences()
        #expect(prefs.featuredCategoryIDs.isEmpty)
    }
}
```

**Step 2: Implement UserPreferences model**

```swift
import Foundation
import SwiftData

@Model
final class UserPreferences {
    var id: UUID
    var currencyCode: String
    var hasCompletedOnboarding: Bool
    var featuredCategoryIDs: [UUID]
    var lastRecurringGenerationDate: Date?

    init(
        id: UUID = UUID(),
        currencyCode: String = "USD",
        hasCompletedOnboarding: Bool = false,
        featuredCategoryIDs: [UUID] = []
    ) {
        self.id = id
        self.currencyCode = currencyCode
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.featuredCategoryIDs = featuredCategoryIDs
    }
}
```

**Step 3: Run tests, verify pass, commit**

---

### Task 6: Migrate Expense model from enum to Category relationship

**Files:**
- Modify: `Xpens/Xpens/Models/Expense.swift`
- Modify: `Xpens/XpensTests/ExpenseTests.swift`
- Modify: All files referencing `expense.category` or `ExpenseCategory`

This is the most impactful migration. The `ExpenseCategory` enum gets replaced by the `Category` model.

**Step 1: Update Expense model**

Replace `categoryRawValue` with a SwiftData relationship and add recurring/tag fields:

```swift
import Foundation
import SwiftData

@Model
final class Expense {
    var id: UUID
    var date: Date
    var amount: Decimal
    var merchant: String
    var client: String
    var notes: String
    var receiptImagePath: String?
    var createdAt: Date

    // Relationships
    var category: Category?
    var tags: [Tag]?

    // Recurring
    var isRecurring: Bool
    var recurrenceRule: String?  // "weekly", "monthly", "yearly"
    var lastGeneratedDate: Date?

    init(
        id: UUID = UUID(),
        date: Date = .now,
        category: Category? = nil,
        amount: Decimal = 0,
        merchant: String = "",
        client: String = "",
        notes: String = "",
        receiptImagePath: String? = nil,
        tags: [Tag]? = nil,
        isRecurring: Bool = false,
        recurrenceRule: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.date = date
        self.category = category
        self.amount = amount
        self.merchant = merchant
        self.client = client
        self.notes = notes
        self.receiptImagePath = receiptImagePath
        self.tags = tags
        self.isRecurring = isRecurring
        self.recurrenceRule = recurrenceRule
        self.createdAt = createdAt
    }
}
```

**Step 2: Delete ExpenseCategory.swift**

Remove the old enum file entirely.

**Step 3: Update model container registration**

In `XpensApp.swift`, register all models:

```swift
.modelContainer(for: [Expense.self, Category.self, Tag.self, UserPreferences.self])
```

**Step 4: Update all views and services**

Every file that references `ExpenseCategory` or `expense.category.displayName` / `.icon` / `.color` must be updated to use the `Category` model. Key files:
- `CategoryPicker.swift` — query categories, show featured + "Other"
- `ExpenseRowView.swift` — use `expense.category?.icon`, `expense.category?.swiftUIColor`
- `ExpenseDetailView.swift` / `ExpenseEditView.swift` — same
- `ExpenseFilterView.swift` — query categories instead of `ExpenseCategory.allCases`
- `ExpenseListView.swift` — filter by `Category` object
- `ManualEntryView.swift` — use new CategoryPicker
- `ReportsView.swift` — group by `Category`
- `ReportPreviewView.swift` — use category name/icon/color
- `CSVExportService.swift` — use `expense.category?.name ?? "Uncategorized"`
- `PDFExportService.swift` — use category model for grouping and display

**Step 5: Update all tests**

All tests that create `Expense` instances need to create a `Category` first and pass it in. Update `ExpenseTests`, `CSVExportServiceTests`, `PDFExportServiceTests`, `ExpenseCategoryTests` (delete this file — replaced by `CategoryModelTests`).

**Step 6: Run full test suite, verify pass**

**Step 7: Commit**

```bash
git commit -m "Migrate from ExpenseCategory enum to Category SwiftData model"
```

---

## Phase 3: Dynamic Currency

### Task 7: Make CurrencyFormatter dynamic

**Files:**
- Modify: `Xpens/Xpens/Utilities/CurrencyFormatter.swift`
- Modify: `Xpens/XpensTests/CurrencyFormatterTests.swift`

**Step 1: Write failing tests for dynamic currency**

```swift
@Test("formats EUR amounts")
func formatsEUR() {
    CurrencyFormatter.setCurrency(code: "EUR")
    let result = CurrencyFormatter.string(from: 1234.56)
    #expect(result.contains("1,234.56") || result.contains("1.234,56"))
    CurrencyFormatter.setCurrency(code: "USD") // reset
}
```

**Step 2: Refactor CurrencyFormatter**

Replace the hardcoded formatter with a configurable one:

```swift
import Foundation

enum CurrencyFormatter {

    private static var formatter: NumberFormatter = makeFormatter(code: "USD")

    private static func makeFormatter(code: String) -> NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = code
        return f
    }

    static func setCurrency(code: String) {
        formatter = makeFormatter(code: code)
    }

    static var currencyCode: String {
        formatter.currencyCode ?? "USD"
    }

    static func string(from amount: Decimal) -> String {
        formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
    }

    static func decimal(from string: String) -> Decimal? {
        let symbols = formatter.currencySymbol ?? "$"
        let cleaned = string
            .replacingOccurrences(of: symbols, with: "")
            .replacingOccurrences(of: formatter.groupingSeparator ?? ",", with: "")
            .trimmingCharacters(in: .whitespaces)
        return Decimal(string: cleaned)
    }
}
```

**Step 3: Initialize currency from UserPreferences on app launch**

In `XpensApp.swift`, read the stored currency code and call `CurrencyFormatter.setCurrency(code:)`.

**Step 4: Run tests, verify pass, commit**

---

## Phase 4: Settings & Onboarding UI

### Task 8: Build Settings screen

**Files:**
- Create: `Xpens/Xpens/Views/Settings/SettingsView.swift`
- Create: `Xpens/Xpens/Views/Settings/ManageCategoriesView.swift`
- Create: `Xpens/Xpens/Views/Settings/FeaturedCategoriesView.swift`
- Create: `Xpens/Xpens/Views/Settings/ManageTagsView.swift`
- Create: `Xpens/Xpens/Views/Settings/CurrencyPickerView.swift`
- Modify: `Xpens/Xpens/Views/MainTabView.swift` — add Settings tab

**SettingsView:** Form with sections for Currency, Categories, Tags, Tip Jar, Backup, About.

**ManageCategoriesView:** List of all categories with swipe-to-delete, add button, edit navigation. Deletion of category with expenses shows reassignment picker.

**FeaturedCategoriesView:** List of all categories with checkmarks on the 4 featured ones. Tap toggles featured status (max 4 enforced).

**ManageTagsView:** Simple list with add/edit/delete for tags. Color picker for each tag.

**CurrencyPickerView:** Searchable list of ISO 4217 currencies. Selection updates UserPreferences and calls `CurrencyFormatter.setCurrency(code:)`.

**MainTabView update:** Add 4th tab:

```swift
Tab("Settings", systemImage: "gear") {
    SettingsView()
}
```

**Commit after each view is built and functional.**

---

### Task 9: Build Onboarding flow

**Files:**
- Create: `Xpens/Xpens/Views/Onboarding/OnboardingView.swift`
- Create: `Xpens/Xpens/Views/Onboarding/WelcomePageView.swift`
- Create: `Xpens/Xpens/Views/Onboarding/CurrencySelectionPageView.swift`
- Create: `Xpens/Xpens/Views/Onboarding/FeaturedCategoriesPageView.swift`
- Modify: `Xpens/Xpens/XpensApp.swift`

**OnboardingView:** TabView with `.page` style, 3 pages. "Skip" button on each page. "Get Started" on last page.

**App entry point:** Check `UserPreferences.hasCompletedOnboarding`. If false, show onboarding. On completion, seed default categories into SwiftData and set `hasCompletedOnboarding = true`.

**Commit after onboarding is functional.**

---

### Task 10: Redesign CategoryPicker with featured + Other

**Files:**
- Modify: `Xpens/Xpens/Views/Components/CategoryPicker.swift`
- Create: `Xpens/Xpens/Views/Components/AllCategoriesSheet.swift`
- Modify: `Xpens/Xpens/Views/AddExpense/ManualEntryView.swift`
- Modify: `Xpens/Xpens/Views/ExpenseDetail/ExpenseDetailView.swift` (ExpenseEditView)

**CategoryPicker redesign:**
- Query UserPreferences for `featuredCategoryIDs`
- Query Category model for the 4 featured categories
- Show 2x2 grid of featured categories
- "Other" card at bottom opens `AllCategoriesSheet`

**AllCategoriesSheet:** Searchable list of all categories, grouped alphabetically. Tap selects and dismisses.

**Commit after picker works end-to-end.**

---

## Phase 5: Tags

### Task 11: Add tag support to expense views

**Files:**
- Modify: `Xpens/Xpens/Views/AddExpense/ManualEntryView.swift` — add tag picker section
- Modify: `Xpens/Xpens/Views/ExpenseDetail/ExpenseDetailView.swift` — show tags
- Modify: `Xpens/Xpens/Views/ExpenseList/ExpenseRowView.swift` — show tag pills
- Modify: `Xpens/Xpens/Views/ExpenseList/ExpenseFilterView.swift` — add tag filter
- Modify: `Xpens/Xpens/Views/ExpenseList/ExpenseListView.swift` — filter by tags
- Create: `Xpens/Xpens/Views/Components/TagPicker.swift`

**TagPicker:** Horizontal scroll of tag chips with + button to create inline. Multi-select.

**ExpenseRowView:** Below the merchant/client/date line, show small colored tag pills.

**ExpenseFilterView:** New "Tags" section with multi-select tag chips.

**Commit after tags flow works end-to-end.**

---

### Task 12: Add tags to export services

**Files:**
- Modify: `Xpens/Xpens/Services/CSVExportService.swift` — add Tags column
- Modify: `Xpens/Xpens/Services/PDFExportService.swift` — add tag breakdown section
- Modify: `Xpens/Xpens/Views/Reports/ReportsView.swift` — tag filter
- Update relevant tests

**CSV:** Add "Tags" column after Notes. Comma-separated tag names within the field (quoted if needed).

**PDF:** After category breakdown in summary, add tag breakdown section showing per-tag totals.

**Reports:** Add tag-based filtering in the filter controls.

**Commit after exports include tags.**

---

## Phase 6: Recurring Expenses

### Task 13: Build RecurringExpenseService

**Files:**
- Create: `Xpens/Xpens/Services/RecurringExpenseService.swift`
- Create: `Xpens/XpensTests/RecurringExpenseServiceTests.swift`

**Step 1: Write failing tests**

Test scenarios:
- Monthly template with last generated date 2 months ago → generates 2 expenses
- Weekly template → generates correct number of weekly entries
- Yearly template → generates yearly entries
- Template with no lastGeneratedDate → generates from template's creation date
- Already up-to-date template → generates nothing

**Step 2: Implement RecurringExpenseService**

```swift
enum RecurringExpenseService {
    static func generatePendingExpenses(
        templates: [Expense],
        modelContext: ModelContext,
        asOf: Date = .now
    ) -> Int { ... }
}
```

Logic: For each recurring template, calculate how many intervals have passed since `lastGeneratedDate` (or `createdAt`). For each interval, insert a new non-recurring Expense cloned from the template with the appropriate date. Update `lastGeneratedDate`.

**Step 3: Run tests, verify pass, commit**

---

### Task 14: Build recurring expense UI

**Files:**
- Modify: `Xpens/Xpens/Views/ExpenseList/ExpenseListView.swift` — recurring section
- Modify: `Xpens/Xpens/Views/AddExpense/ManualEntryView.swift` — frequency picker
- Modify: `Xpens/Xpens/XpensApp.swift` — call generation on launch
- Create: `Xpens/Xpens/Views/ExpenseList/RecurringExpenseRow.swift`

**ExpenseListView:** Section above the monthly groups showing active recurring templates. Each row shows category icon, merchant, amount, frequency, and next date.

**ManualEntryView:** New toggle "Make Recurring" at bottom of form. When enabled, shows frequency picker (Weekly / Monthly / Yearly).

**App launch:** In `XpensApp.init` or `.onAppear` of `MainTabView`, call `RecurringExpenseService.generatePendingExpenses()`.

**Commit after recurring flow works end-to-end.**

---

## Phase 7: iCloud Backup/Restore

### Task 15: Build BackupService

**Files:**
- Create: `Xpens/Xpens/Services/BackupService.swift`
- Modify: `Xpens/Xpens/Views/Settings/SettingsView.swift` — backup/restore section

**BackupService:**
- `backup(modelContext:) async throws` — Exports all Expense, Category, Tag, UserPreferences as JSON + copies receipt images into a timestamped `.xpensbackup` directory in the app's iCloud Documents container
- `listBackups() -> [BackupInfo]` — Lists available backups with date, expense count, file size
- `restore(from:modelContext:) async throws` — Deletes all local data, imports from backup archive
- `deleteBackup(_:) throws` — Removes a backup

**iCloud entitlement:** Add `com.apple.developer.icloud-container-identifiers` to project.yml entitlements with `iCloud.com.xpens.app`.

**Settings UI:** "Back Up Now" button with progress indicator, list of existing backups with restore/delete actions, size estimate.

**Commit after backup/restore is functional.**

---

## Phase 8: Tip Jar

### Task 16: Implement StoreKit 2 tip jar

**Files:**
- Create: `Xpens/Xpens/Services/TipJarService.swift`
- Create: `Xpens/Xpens/Views/Settings/TipJarView.swift`
- Modify: `Xpens/Xpens/Views/Settings/SettingsView.swift` — embed TipJarView

**TipJarService:** Wraps StoreKit 2 `Product` and `Transaction` APIs. Three product IDs: `com.xpens.tip.coffee`, `com.xpens.tip.lunch`, `com.xpens.tip.dinner`. Handles purchase flow and transaction verification.

**TipJarView:** Friendly copy ("Xpens is free forever. If it's saved you time, consider leaving a tip!"). Three buttons with emoji and price. Thank-you state after purchase.

**StoreKit configuration:** Create `Xpens/Xpens/Configuration.storekit` for testing in sandbox.

**Commit after tip jar purchases work in sandbox.**

---

## Phase 9: Polish & Ship

### Task 17: Update CLAUDE.md, README.md, and memory

**Files:**
- Modify: `CLAUDE.md`
- Modify: `README.md`
- Modify: memory file

Update all documentation to reflect Xpens branding, new architecture (Category/Tag models, UserPreferences, dynamic currency), new features (recurring, backup, tip jar), and updated build commands.

**Commit after docs are updated.**

---

### Task 18: Final integration test

**Steps:**
1. Delete app from simulator, fresh install
2. Verify onboarding flow completes
3. Add expense with OCR scan
4. Add expense manually with custom category and tags
5. Set up a recurring expense, force-quit and relaunch, verify generation
6. Export PDF and CSV, verify tags and correct currency
7. Backup to iCloud, delete app, reinstall, restore
8. Purchase tip (sandbox)
9. Run full test suite — all tests pass

**Commit any fixes found during integration testing.**

---

## Task Dependency Summary

```
Phase 1: Rebrand (Tasks 1-2)
    ↓
Phase 2: Data Models (Tasks 3-6) — sequential, each builds on prior
    ↓
Phase 3: Dynamic Currency (Task 7)
    ↓
Phase 4: Settings & Onboarding (Tasks 8-10) — can partially parallelize 8 and 9
    ↓
Phase 5: Tags (Tasks 11-12)
    ↓
Phase 6: Recurring Expenses (Tasks 13-14)
    ↓
Phase 7: iCloud Backup (Task 15)
    ↓
Phase 8: Tip Jar (Task 16)
    ↓
Phase 9: Polish (Tasks 17-18)
```
