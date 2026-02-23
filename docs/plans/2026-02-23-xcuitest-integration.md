# XCUITest Integration Suite Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a UI test suite that automates the Task 18 integration test steps — onboarding, manual expense entry with category and tags, recurring expense verification, reports navigation, and settings navigation.

**Architecture:** Centralized `AccessibilityID` enum shared between production views and XCUITests. Launch arguments (`--uitesting-reset`, `--uitesting-skip-onboarding`) control app state per test. New `XpensUITests` target in `project.yml`.

**Tech Stack:** XCTest/XCUITest, Swift 6, XcodeGen

---

## Task 1: Create AccessibilityID enum

**Files:**
- Create: `Xpens/Xpens/Utilities/AccessibilityID.swift`

**Step 1: Create the centralized identifiers file**

```swift
import Foundation

enum AccessibilityID {
    enum Onboarding {
        static let skipButton = "onboarding-skip"
        static let nextButton = "onboarding-next"
        static let getStartedButton = "onboarding-get-started"
        static let currencyList = "onboarding-currency-list"
        static let categoriesList = "onboarding-categories-list"
    }

    enum Tabs {
        static let expenses = "tab-expenses"
        static let addExpense = "tab-add-expense"
        static let reports = "tab-reports"
        static let settings = "tab-settings"
    }

    enum ExpenseList {
        static let addButton = "expense-list-add"
        static let filterButton = "expense-list-filter"
        static let list = "expense-list"
        static let emptyState = "expense-list-empty"
        static let recurringSection = "expense-list-recurring"
    }

    enum ManualEntry {
        static let amountField = "manual-entry-amount"
        static let merchantField = "manual-entry-merchant"
        static let clientField = "manual-entry-client"
        static let notesField = "manual-entry-notes"
        static let saveButton = "manual-entry-save"
        static let cancelButton = "manual-entry-cancel"
        static let recurringToggle = "manual-entry-recurring-toggle"
        static let frequencyPicker = "manual-entry-frequency"
    }

    enum CategoryPicker {
        static let otherButton = "category-picker-other"
        static let allCategoriesSheet = "all-categories-sheet"
    }

    enum TagPicker {
        static let newButton = "tag-picker-new"
        static let tagNameField = "tag-picker-name-field"
        static let addButton = "tag-picker-add"
        static let cancelButton = "tag-picker-cancel"
    }

    enum Reports {
        static let viewReportButton = "reports-view-report"
        static let totalAmount = "reports-total-amount"
        static let categoryChart = "reports-category-chart"
    }

    enum Settings {
        static let currencyRow = "settings-currency"
        static let manageCategoriesRow = "settings-manage-categories"
        static let featuredCategoriesRow = "settings-featured-categories"
        static let manageTagsRow = "settings-manage-tags"
        static let tipJarRow = "settings-tip-jar"
        static let backupRow = "settings-backup"
        static let versionLabel = "settings-version"
    }

    enum ManageCategories {
        static let addButton = "manage-categories-add"
        static let list = "manage-categories-list"
    }

    enum ManageTags {
        static let addButton = "manage-tags-add"
        static let list = "manage-tags-list"
    }
}
```

**Step 2: Verify it compiles**

```bash
cd Xpens && xcodegen generate && xcodebuild -project Xpens.xcodeproj -scheme Xpens \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | tail -5
```

Expected: `BUILD SUCCEEDED`

**Step 3: Commit**

```bash
git add Xpens/Xpens/Utilities/AccessibilityID.swift
git commit -m "Add centralized AccessibilityID enum for UI testing"
```

---

## Task 2: Wire accessibility identifiers into views

**Files:**
- Modify: `Xpens/Xpens/Views/Onboarding/OnboardingView.swift`
- Modify: `Xpens/Xpens/Views/MainTabView.swift`
- Modify: `Xpens/Xpens/Views/ExpenseList/ExpenseListView.swift`
- Modify: `Xpens/Xpens/Views/AddExpense/ManualEntryView.swift`
- Modify: `Xpens/Xpens/Views/Components/CategoryPicker.swift`
- Modify: `Xpens/Xpens/Views/Components/TagPicker.swift`
- Modify: `Xpens/Xpens/Views/Reports/ReportsView.swift`
- Modify: `Xpens/Xpens/Views/Settings/SettingsView.swift`
- Modify: `Xpens/Xpens/Views/Settings/ManageCategoriesView.swift`
- Modify: `Xpens/Xpens/Views/Settings/ManageTagsView.swift`

**Step 1: Add identifiers to OnboardingView**

In `OnboardingView.swift`, add `.accessibilityIdentifier()` modifiers:

- On the `Button("Skip")` — add `.accessibilityIdentifier(AccessibilityID.Onboarding.skipButton)`
- On the `Button("Next")` — add `.accessibilityIdentifier(AccessibilityID.Onboarding.nextButton)`
- On the `Button("Get Started")` — add `.accessibilityIdentifier(AccessibilityID.Onboarding.getStartedButton)`

**Step 2: Add identifiers to MainTabView**

In `MainTabView.swift`, add `.accessibilityIdentifier()` to each `Tab`:

```swift
Tab("Expenses", systemImage: "list.bullet") {
    ExpenseListView()
}
.accessibilityIdentifier(AccessibilityID.Tabs.expenses)

Tab("Add Expense", systemImage: "plus.circle") {
    AddExpenseView()
}
.accessibilityIdentifier(AccessibilityID.Tabs.addExpense)

Tab("Reports", systemImage: "chart.bar") {
    ReportsView()
}
.accessibilityIdentifier(AccessibilityID.Tabs.reports)

Tab("Settings", systemImage: "gear") {
    SettingsView()
}
.accessibilityIdentifier(AccessibilityID.Tabs.settings)
```

**Step 3: Add identifiers to ExpenseListView**

- On the `Button` wrapping `Image(systemName: "plus")` in toolbar — add `.accessibilityIdentifier(AccessibilityID.ExpenseList.addButton)`
- On the `filterButton` computed property's Button — add `.accessibilityIdentifier(AccessibilityID.ExpenseList.filterButton)`
- On the `List` in `expenseList` — add `.accessibilityIdentifier(AccessibilityID.ExpenseList.list)`
- On the `ContentUnavailableView` in `emptyState` — add `.accessibilityIdentifier(AccessibilityID.ExpenseList.emptyState)`
- On the `Section("Recurring")` — add `.accessibilityIdentifier(AccessibilityID.ExpenseList.recurringSection)` to the section's content or the ForEach's parent

**Step 4: Add identifiers to ManualEntryView**

- On `CurrencyTextField` — add `.accessibilityIdentifier(AccessibilityID.ManualEntry.amountField)`
- On `TextField("Merchant", ...)` — add `.accessibilityIdentifier(AccessibilityID.ManualEntry.merchantField)`
- On `TextField("Client", ...)` — add `.accessibilityIdentifier(AccessibilityID.ManualEntry.clientField)`
- On `TextField("Notes", ...)` — add `.accessibilityIdentifier(AccessibilityID.ManualEntry.notesField)`
- On the `Button("Save")` — add `.accessibilityIdentifier(AccessibilityID.ManualEntry.saveButton)`
- On the `Button("Cancel")` — add `.accessibilityIdentifier(AccessibilityID.ManualEntry.cancelButton)`
- On `Toggle("Make Recurring", ...)` — add `.accessibilityIdentifier(AccessibilityID.ManualEntry.recurringToggle)`
- On `Picker("Frequency", ...)` — add `.accessibilityIdentifier(AccessibilityID.ManualEntry.frequencyPicker)`

**Step 5: Add identifiers to CategoryPicker**

- On the "Other" `Button` — add `.accessibilityIdentifier(AccessibilityID.CategoryPicker.otherButton)`
- On `AllCategoriesSheet`'s outermost view — add `.accessibilityIdentifier(AccessibilityID.CategoryPicker.allCategoriesSheet)` (note: `AllCategoriesSheet` is private, so use the identifier on the `.sheet` content view's NavigationStack)

**Step 6: Add identifiers to TagPicker**

- On the "New" `Button` — add `.accessibilityIdentifier(AccessibilityID.TagPicker.newButton)`
- On the `TextField("Tag name", ...)` — add `.accessibilityIdentifier(AccessibilityID.TagPicker.tagNameField)`
- On `Button("Add")` — add `.accessibilityIdentifier(AccessibilityID.TagPicker.addButton)`
- On `Button("Cancel")` in the new tag form — add `.accessibilityIdentifier(AccessibilityID.TagPicker.cancelButton)`

**Step 7: Add identifiers to ReportsView**

- On the `NavigationLink` containing "View Full Report" — add `.accessibilityIdentifier(AccessibilityID.Reports.viewReportButton)`
- On the `Text(CurrencyFormatter.string(from: total))` — add `.accessibilityIdentifier(AccessibilityID.Reports.totalAmount)`
- On the `Chart` — add `.accessibilityIdentifier(AccessibilityID.Reports.categoryChart)`

**Step 8: Add identifiers to SettingsView**

- On the "Default Currency" `NavigationLink` — add `.accessibilityIdentifier(AccessibilityID.Settings.currencyRow)`
- On "Manage Categories" `NavigationLink` — add `.accessibilityIdentifier(AccessibilityID.Settings.manageCategoriesRow)`
- On "Featured Categories" `NavigationLink` — add `.accessibilityIdentifier(AccessibilityID.Settings.featuredCategoriesRow)`
- On "Manage Tags" `NavigationLink` — add `.accessibilityIdentifier(AccessibilityID.Settings.manageTagsRow)`
- On "Tip Jar" `NavigationLink` — add `.accessibilityIdentifier(AccessibilityID.Settings.tipJarRow)`
- On "Backup & Restore" `NavigationLink` — add `.accessibilityIdentifier(AccessibilityID.Settings.backupRow)`
- On the version `Text("1.0")` — add `.accessibilityIdentifier(AccessibilityID.Settings.versionLabel)`

**Step 9: Add identifiers to ManageCategoriesView and ManageTagsView**

- `ManageCategoriesView`: On the `Button` with `Image(systemName: "plus")` — add `.accessibilityIdentifier(AccessibilityID.ManageCategories.addButton)`
- `ManageCategoriesView`: On the `List` — add `.accessibilityIdentifier(AccessibilityID.ManageCategories.list)`
- `ManageTagsView`: On the `Button` with `Image(systemName: "plus")` — add `.accessibilityIdentifier(AccessibilityID.ManageTags.addButton)`
- `ManageTagsView`: On the `List` — add `.accessibilityIdentifier(AccessibilityID.ManageTags.list)`

**Step 10: Build and run existing unit tests to verify nothing is broken**

```bash
cd Xpens && xcodegen generate && xcodebuild -project Xpens.xcodeproj -scheme Xpens \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test 2>&1 | tail -5
```

Expected: `TEST SUCCEEDED` with 82 tests passing.

**Step 11: Commit**

```bash
git add -A
git commit -m "Add accessibility identifiers to views for UI testing"
```

---

## Task 3: Add launch argument handling in XpensApp

**Files:**
- Modify: `Xpens/Xpens/XpensApp.swift`

**Step 1: Add `#if DEBUG` launch argument handling to `XpensApp.init()`**

At the top of `init()`, before the existing `ModelContainer` setup, add:

```swift
#if DEBUG
let isUITestingReset = CommandLine.arguments.contains("--uitesting-reset")
let isUITestingSkipOnboarding = CommandLine.arguments.contains("--uitesting-skip-onboarding")
#endif
```

Then, after `let container = try! ModelContainer(...)`, add the reset logic:

```swift
#if DEBUG
if isUITestingReset {
    // Delete all existing data for a clean slate
    let context = container.mainContext
    try? context.delete(model: Expense.self)
    try? context.delete(model: Category.self)
    try? context.delete(model: Tag.self)
    try? context.delete(model: UserPreferences.self)
    try? context.save()
}
if isUITestingSkipOnboarding {
    let context = container.mainContext
    let existingPrefs = (try? context.fetch(FetchDescriptor<UserPreferences>()))?.first
    if existingPrefs == nil {
        // Seed default categories
        let categories = Category.createDefaults()
        for cat in categories { context.insert(cat) }
        // Create preferences with onboarding completed
        let prefs = UserPreferences(
            currencyCode: "USD",
            hasCompletedOnboarding: true,
            featuredCategoryIDs: Array(categories.prefix(4).map(\.id))
        )
        context.insert(prefs)
        try? context.save()
    }
}
#endif
```

Place this BEFORE the existing `let prefs = (try? context.fetch(...)` line so that the seeded data is available for the currency setup that follows.

The final `init()` order should be:
1. Create `ModelContainer`
2. `#if DEBUG` reset/skip-onboarding handling
3. Existing currency setup from prefs
4. Existing recurring expense generation

**Step 2: Build and run unit tests**

```bash
cd Xpens && xcodegen generate && xcodebuild -project Xpens.xcodeproj -scheme Xpens \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test 2>&1 | tail -5
```

Expected: `TEST SUCCEEDED` — launch arguments are not present during unit tests, so the DEBUG blocks are harmless.

**Step 3: Commit**

```bash
git add Xpens/Xpens/XpensApp.swift
git commit -m "Add launch argument handling for UI test state control"
```

---

## Task 4: Add XpensUITests target to project.yml

**Files:**
- Modify: `Xpens/project.yml`
- Create: `Xpens/XpensUITests/` directory

**Step 1: Add the UI test target to project.yml**

Add this as a new target after `XpensTests`:

```yaml
  XpensUITests:
    type: bundle.ui-testing
    platform: iOS
    sources:
      - XpensUITests
    dependencies:
      - target: Xpens
    settings:
      base:
        GENERATE_INFOPLIST_FILE: true
        PRODUCT_BUNDLE_IDENTIFIER: com.xpens.app.uitests
        TEST_TARGET_NAME: Xpens
```

**Step 2: Create the XpensUITests directory and a placeholder test**

Create `Xpens/XpensUITests/XpensUITestCase.swift`:

```swift
import XCTest

class XpensUITestCase: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    /// Launch with clean state (onboarding will show)
    func launchFreshApp() {
        app.launchArguments = ["--uitesting-reset"]
        app.launch()
    }

    /// Launch with onboarding already complete and default categories seeded
    func launchSeededApp() {
        app.launchArguments = ["--uitesting-reset", "--uitesting-skip-onboarding"]
        app.launch()
    }
}
```

**Step 3: Regenerate project and verify build**

```bash
cd Xpens && xcodegen generate && xcodebuild -project Xpens.xcodeproj -scheme Xpens \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build-for-testing 2>&1 | tail -5
```

Expected: `BUILD SUCCEEDED`

**Step 4: Commit**

```bash
git add Xpens/project.yml Xpens/XpensUITests/
git commit -m "Add XpensUITests target with base test case class"
```

---

## Task 5: Write OnboardingUITests

**Files:**
- Create: `Xpens/XpensUITests/OnboardingUITests.swift`

**Step 1: Write the test file**

```swift
import XCTest

final class OnboardingUITests: XpensUITestCase {

    func testCompleteOnboardingFlow() throws {
        launchFreshApp()

        // Page 1: Welcome — tap Next
        let nextButton = app.buttons["onboarding-next"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5))
        nextButton.tap()

        // Page 2: Currency — tap Next (USD is pre-selected)
        // Wait for the next button to be hittable again after page transition
        let nextButton2 = app.buttons["onboarding-next"]
        XCTAssertTrue(nextButton2.waitForExistence(timeout: 3))
        nextButton2.tap()

        // Page 3: Featured Categories — tap Get Started
        let getStartedButton = app.buttons["onboarding-get-started"]
        XCTAssertTrue(getStartedButton.waitForExistence(timeout: 3))
        getStartedButton.tap()

        // Verify MainTabView appeared
        let expensesTab = app.buttons["tab-expenses"]
        XCTAssertTrue(expensesTab.waitForExistence(timeout: 5))
    }

    func testSkipOnboarding() throws {
        launchFreshApp()

        let skipButton = app.buttons["onboarding-skip"]
        XCTAssertTrue(skipButton.waitForExistence(timeout: 5))
        skipButton.tap()

        // Verify MainTabView appeared
        let expensesTab = app.buttons["tab-expenses"]
        XCTAssertTrue(expensesTab.waitForExistence(timeout: 5))
    }

    func testOnboardingShowsAllThreePages() throws {
        launchFreshApp()

        // Page 1: Welcome content visible
        XCTAssertTrue(app.staticTexts["Welcome to Xpens"].waitForExistence(timeout: 5))

        // Advance to Page 2: Currency
        app.buttons["onboarding-next"].tap()
        XCTAssertTrue(app.navigationBars["Currency"].waitForExistence(timeout: 3)
            || app.staticTexts["USD"].waitForExistence(timeout: 3))

        // Advance to Page 3: Featured Categories
        app.buttons["onboarding-next"].tap()
        XCTAssertTrue(app.staticTexts["0/4 selected"].waitForExistence(timeout: 3)
            || app.staticTexts["4/4 selected"].waitForExistence(timeout: 3))
    }
}
```

**Step 2: Run the UI tests**

```bash
cd Xpens && xcodebuild -project Xpens.xcodeproj -scheme Xpens \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:XpensUITests/OnboardingUITests test 2>&1 | tail -20
```

Expected: All 3 tests pass. If any assertions fail due to text mismatches (e.g., the welcome page uses different wording), update the assertions to match the actual view content — read `WelcomePageView.swift` and `FeaturedCategoriesPageView.swift` for exact strings.

**Step 3: Commit**

```bash
git add Xpens/XpensUITests/OnboardingUITests.swift
git commit -m "Add onboarding UI tests"
```

---

## Task 6: Write ManualExpenseUITests

**Files:**
- Create: `Xpens/XpensUITests/ManualExpenseUITests.swift`

**Step 1: Write the test file**

```swift
import XCTest

final class ManualExpenseUITests: XpensUITestCase {

    func testAddExpenseManually() throws {
        launchSeededApp()

        // Tap the add button in the toolbar
        let addButton = app.buttons["expense-list-add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        // Fill in merchant
        let merchantField = app.textFields["manual-entry-merchant"]
        XCTAssertTrue(merchantField.waitForExistence(timeout: 3))
        merchantField.tap()
        merchantField.typeText("Test Coffee Shop")

        // Fill in amount — CurrencyTextField is a TextField under the hood
        let amountField = app.textFields["manual-entry-amount"]
        XCTAssertTrue(amountField.exists)
        amountField.tap()
        amountField.typeText("12.50")

        // Select a category — tap the first featured category card
        // Featured categories are seeded, so at least one card should be visible
        let categoryCards = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Airline'"))
        if categoryCards.count > 0 {
            categoryCards.firstMatch.tap()
        }

        // Save
        let saveButton = app.buttons["manual-entry-save"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()

        // Verify expense appears in the list
        XCTAssertTrue(app.staticTexts["Test Coffee Shop"].waitForExistence(timeout: 3))
    }

    func testAddExpenseWithTag() throws {
        launchSeededApp()

        // Open add expense
        let addButton = app.buttons["expense-list-add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        // Fill required fields
        let merchantField = app.textFields["manual-entry-merchant"]
        XCTAssertTrue(merchantField.waitForExistence(timeout: 3))
        merchantField.tap()
        merchantField.typeText("Tagged Merchant")

        let amountField = app.textFields["manual-entry-amount"]
        amountField.tap()
        amountField.typeText("25.00")

        // Create a new tag inline
        let newTagButton = app.buttons["tag-picker-new"]
        // Scroll down to find tags section if needed
        if !newTagButton.isHittable {
            app.swipeUp()
        }
        XCTAssertTrue(newTagButton.waitForExistence(timeout: 3))
        newTagButton.tap()

        let tagNameField = app.textFields["tag-picker-name-field"]
        XCTAssertTrue(tagNameField.waitForExistence(timeout: 3))
        tagNameField.tap()
        tagNameField.typeText("business")

        let addTagButton = app.buttons["tag-picker-add"]
        addTagButton.tap()

        // Save
        app.buttons["manual-entry-save"].tap()

        // Verify expense appears
        XCTAssertTrue(app.staticTexts["Tagged Merchant"].waitForExistence(timeout: 3))
    }
}
```

**Step 2: Run the tests**

```bash
cd Xpens && xcodebuild -project Xpens.xcodeproj -scheme Xpens \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:XpensUITests/ManualExpenseUITests test 2>&1 | tail -20
```

Expected: Both tests pass. If `CurrencyTextField` doesn't expose the accessibility identifier to its inner `TextField`, you may need to add `.accessibilityIdentifier(AccessibilityID.ManualEntry.amountField)` on the inner `TextField` inside `CurrencyTextField.swift` — read that file and adjust.

**Step 3: Commit**

```bash
git add Xpens/XpensUITests/ManualExpenseUITests.swift
git commit -m "Add manual expense entry UI tests"
```

---

## Task 7: Write RecurringExpenseUITests

**Files:**
- Create: `Xpens/XpensUITests/RecurringExpenseUITests.swift`

**Step 1: Write the test file**

```swift
import XCTest

final class RecurringExpenseUITests: XpensUITestCase {

    func testCreateRecurringExpense() throws {
        launchSeededApp()

        // Open add expense
        let addButton = app.buttons["expense-list-add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        // Fill required fields
        let merchantField = app.textFields["manual-entry-merchant"]
        XCTAssertTrue(merchantField.waitForExistence(timeout: 3))
        merchantField.tap()
        merchantField.typeText("Monthly Subscription")

        let amountField = app.textFields["manual-entry-amount"]
        amountField.tap()
        amountField.typeText("9.99")

        // Scroll down to find the recurring toggle
        app.swipeUp()

        // Enable recurring
        let recurringToggle = app.switches["manual-entry-recurring-toggle"]
        XCTAssertTrue(recurringToggle.waitForExistence(timeout: 3))
        recurringToggle.tap()

        // Verify frequency picker appears (defaults to monthly)
        let frequencyPicker = app.buttons["manual-entry-frequency"]
            .firstMatch
        // The picker should exist after toggle is on
        XCTAssertTrue(frequencyPicker.waitForExistence(timeout: 2)
            || app.staticTexts["Monthly"].waitForExistence(timeout: 2))

        // Save
        app.buttons["manual-entry-save"].tap()

        // Verify the recurring section appears in the list
        XCTAssertTrue(app.staticTexts["Monthly Subscription"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Recurring"].waitForExistence(timeout: 3)
            || app.staticTexts["Monthly"].waitForExistence(timeout: 3))
    }

    func testRecurringExpenseAppearsAfterRelaunch() throws {
        launchSeededApp()

        // Create a recurring expense
        app.buttons["expense-list-add"].tap()
        let merchantField = app.textFields["manual-entry-merchant"]
        XCTAssertTrue(merchantField.waitForExistence(timeout: 3))
        merchantField.tap()
        merchantField.typeText("Relaunch Test")
        app.textFields["manual-entry-amount"].tap()
        app.textFields["manual-entry-amount"].typeText("5.00")
        app.swipeUp()
        app.switches["manual-entry-recurring-toggle"].tap()
        app.buttons["manual-entry-save"].tap()

        // Verify it's in the list
        XCTAssertTrue(app.staticTexts["Relaunch Test"].waitForExistence(timeout: 3))

        // Relaunch the app (without --uitesting-reset, so data persists)
        app.terminate()
        app.launchArguments = [] // No reset — keep data
        app.launch()

        // Verify the recurring expense still shows
        XCTAssertTrue(app.staticTexts["Relaunch Test"].waitForExistence(timeout: 5))
    }
}
```

**Step 2: Run the tests**

```bash
cd Xpens && xcodebuild -project Xpens.xcodeproj -scheme Xpens \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:XpensUITests/RecurringExpenseUITests test 2>&1 | tail -20
```

Expected: Both tests pass.

**Step 3: Commit**

```bash
git add Xpens/XpensUITests/RecurringExpenseUITests.swift
git commit -m "Add recurring expense UI tests"
```

---

## Task 8: Write ReportsUITests

**Files:**
- Create: `Xpens/XpensUITests/ReportsUITests.swift`

**Step 1: Write the test file**

```swift
import XCTest

final class ReportsUITests: XpensUITestCase {

    func testReportsScreenLoads() throws {
        launchSeededApp()

        // Navigate to Reports tab
        let reportsTab = app.buttons["tab-reports"]
        XCTAssertTrue(reportsTab.waitForExistence(timeout: 5))
        reportsTab.tap()

        // Verify Reports screen elements
        XCTAssertTrue(app.navigationBars["Reports"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Date Range"].waitForExistence(timeout: 3))
    }

    func testReportsWithExpenseShowsChart() throws {
        launchSeededApp()

        // First add an expense so there's data for the chart
        app.buttons["expense-list-add"].tap()
        let merchantField = app.textFields["manual-entry-merchant"]
        XCTAssertTrue(merchantField.waitForExistence(timeout: 3))
        merchantField.tap()
        merchantField.typeText("Chart Test")
        app.textFields["manual-entry-amount"].tap()
        app.textFields["manual-entry-amount"].typeText("100.00")
        app.buttons["manual-entry-save"].tap()

        // Wait for dismiss
        XCTAssertTrue(app.staticTexts["Chart Test"].waitForExistence(timeout: 3))

        // Navigate to Reports tab
        app.buttons["tab-reports"].tap()

        // Verify total amount is displayed
        let totalAmount = app.staticTexts["reports-total-amount"]
        XCTAssertTrue(totalAmount.waitForExistence(timeout: 3))

        // Verify View Full Report button exists
        let viewReportButton = app.buttons["reports-view-report"]
            .firstMatch
        XCTAssertTrue(viewReportButton.waitForExistence(timeout: 3)
            || app.staticTexts["View Full Report"].waitForExistence(timeout: 3))
    }
}
```

**Step 2: Run the tests**

```bash
cd Xpens && xcodebuild -project Xpens.xcodeproj -scheme Xpens \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:XpensUITests/ReportsUITests test 2>&1 | tail -20
```

Expected: Both tests pass.

**Step 3: Commit**

```bash
git add Xpens/XpensUITests/ReportsUITests.swift
git commit -m "Add reports UI tests"
```

---

## Task 9: Write SettingsUITests

**Files:**
- Create: `Xpens/XpensUITests/SettingsUITests.swift`

**Step 1: Write the test file**

```swift
import XCTest

final class SettingsUITests: XpensUITestCase {

    func testSettingsScreenLoads() throws {
        launchSeededApp()

        // Navigate to Settings tab
        let settingsTab = app.buttons["tab-settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        // Verify Settings screen elements
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))

        // Check all navigation rows exist
        XCTAssertTrue(app.cells["settings-currency"].waitForExistence(timeout: 3)
            || app.staticTexts["Default Currency"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Manage Categories"].exists)
        XCTAssertTrue(app.staticTexts["Manage Tags"].exists)
        XCTAssertTrue(app.staticTexts["Version"].exists)
    }

    func testNavigateToCurrencyPicker() throws {
        launchSeededApp()

        app.buttons["tab-settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))

        // Tap currency row
        let currencyRow = app.cells["settings-currency"].firstMatch
        if currencyRow.exists {
            currencyRow.tap()
        } else {
            app.staticTexts["Default Currency"].tap()
        }

        // Verify Currency picker screen
        XCTAssertTrue(app.navigationBars["Currency"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["USD"].waitForExistence(timeout: 3))
    }

    func testNavigateToManageCategories() throws {
        launchSeededApp()

        app.buttons["tab-settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))

        // Tap manage categories
        app.staticTexts["Manage Categories"].tap()

        // Verify Categories screen
        XCTAssertTrue(app.navigationBars["Categories"].waitForExistence(timeout: 3))

        // Default categories should be listed (8 defaults)
        XCTAssertTrue(app.staticTexts["Food"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Hotel"].exists)
    }
}
```

**Step 2: Run the tests**

```bash
cd Xpens && xcodebuild -project Xpens.xcodeproj -scheme Xpens \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:XpensUITests/SettingsUITests test 2>&1 | tail -20
```

Expected: All 3 tests pass.

**Step 3: Commit**

```bash
git add Xpens/XpensUITests/SettingsUITests.swift
git commit -m "Add settings UI tests"
```

---

## Task 10: Run full test suite (unit + UI) and fix any issues

**Step 1: Run all tests together**

```bash
cd Xpens && xcodegen generate && xcodebuild -project Xpens.xcodeproj -scheme Xpens \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test 2>&1 | tail -30
```

Expected: All 82 unit tests + 12 UI tests pass (`TEST SUCCEEDED`).

**Step 2: Fix any failures**

If any UI tests fail:
- Read the failure message for the specific assertion that failed
- Check if the accessibility identifier is correctly wired (read the view file)
- Check if `CurrencyTextField` needs internal identifier passthrough
- Check if text assertions match actual view content
- Adjust and rerun the failing test in isolation first

**Step 3: Commit any fixes**

```bash
git add -A
git commit -m "Fix UI test issues found during full test run"
```

---

## Task Dependency Summary

```
Task 1: AccessibilityID enum
    ↓
Task 2: Wire identifiers into views
    ↓
Task 3: Launch argument handling
    ↓
Task 4: UI test target + base class
    ↓
Tasks 5-9: Individual test classes (can be written in any order, but run after Task 4)
    ↓
Task 10: Full test run + fix
```
