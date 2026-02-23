# XCUITest Integration Suite Design

## Goal

Automate the Task 18 integration test steps from the Xpens v1 plan that can be reliably automated in CI. Manual-only steps (OCR camera scan, iCloud backup/restore, StoreKit sandbox purchase) are excluded.

## Architecture

### 1. Centralized Accessibility Identifiers

`AccessibilityID` enum in `Xpens/Xpens/Utilities/AccessibilityID.swift` with nested enums per screen. Shared by production views and the UI test target — single source of truth prevents drift.

### 2. Launch Argument State Control

`XpensApp.swift` checks for two `#if DEBUG`-gated launch arguments:

- `--uitesting-reset` — Deletes SwiftData store on launch. Used by onboarding tests for a clean slate.
- `--uitesting-skip-onboarding` — Seeds default categories + UserPreferences with `hasCompletedOnboarding = true`. Used by all post-onboarding tests.

### 3. XpensUITests Target

New `bundle.ui-testing` target in `project.yml`. Test files organized by flow, each class sets its own launch arguments.

## Test Flows

| Class | Tests | Validates |
|-------|-------|-----------|
| `OnboardingUITests` | 3 | Welcome page → Currency selection → Featured categories → MainTabView appears |
| `ManualExpenseUITests` | 2 | Add expense with category + tags; verify it appears in list |
| `RecurringExpenseUITests` | 2 | Create recurring expense; verify recurring section; relaunch and verify generation |
| `ReportsUITests` | 2 | Navigate to reports; verify chart; tap View Full Report |
| `SettingsUITests` | 3 | Navigate currency, category management, tag management |

## Accessibility Identifiers

~30-40 identifiers organized as:

```
AccessibilityID.Onboarding.skipButton / .nextButton / .getStartedButton
AccessibilityID.Tabs.expenses / .addExpense / .reports / .settings
AccessibilityID.ManualEntry.merchantField / .amountField / .saveButton / ...
AccessibilityID.ExpenseList.addButton / .filterButton / .list
AccessibilityID.Settings.currencyRow / .categoriesRow / .tagsRow / ...
AccessibilityID.Reports.viewReportButton / .categoryChart
```

## Excluded (Manual QA Only)

- OCR scan (requires camera hardware)
- iCloud backup/restore (requires real iCloud account)
- StoreKit sandbox purchase (flaky in CI, works best tested manually)
