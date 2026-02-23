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
