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

        // Enable recurring — use firstMatch in case there are multiple matches
        let recurringToggle = app.switches.matching(identifier: "manual-entry-recurring-toggle").firstMatch
        XCTAssertTrue(recurringToggle.waitForExistence(timeout: 3))
        recurringToggle.switches.firstMatch.tap()

        // Scroll down again so the frequency picker is visible
        app.swipeUp()

        // Verify frequency picker appears — check for the footer text which is always a StaticText
        let footerText = app.staticTexts["A new expense will be created automatically at this frequency."]
        XCTAssertTrue(footerText.waitForExistence(timeout: 3),
                       "Recurring section footer should appear after enabling recurring")

        // Save
        let saveButton = app.buttons["manual-entry-save"]
        if !saveButton.isHittable {
            app.swipeDown()
        }
        saveButton.tap()

        // Verify the expense appears in the list with recurring indicator
        XCTAssertTrue(app.staticTexts["Monthly Subscription"].waitForExistence(timeout: 3))
        // The section header "Recurring" or the "Monthly" badge should be visible
        let recurringHeader = app.staticTexts["Recurring"]
        let monthlyBadge = app.staticTexts["Monthly"]
        XCTAssertTrue(recurringHeader.waitForExistence(timeout: 3) || monthlyBadge.exists,
                       "Recurring section header or Monthly badge should appear")
    }

    func testRecurringExpensePersistsAcrossTabs() throws {
        launchSeededApp()

        // Create a recurring expense
        let addButton = app.buttons["expense-list-add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()
        let merchantField = app.textFields["manual-entry-merchant"]
        XCTAssertTrue(merchantField.waitForExistence(timeout: 3))
        merchantField.tap()
        merchantField.typeText("Persistent Recurring")
        app.textFields["manual-entry-amount"].tap()
        app.textFields["manual-entry-amount"].typeText("5.00")
        app.swipeUp()
        let toggle = app.switches.matching(identifier: "manual-entry-recurring-toggle").firstMatch
        XCTAssertTrue(toggle.waitForExistence(timeout: 3))
        toggle.switches.firstMatch.tap()

        // Scroll up to reach the Save button
        app.swipeDown()
        app.buttons["manual-entry-save"].tap()

        // Verify it's in the list
        XCTAssertTrue(app.staticTexts["Persistent Recurring"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Recurring"].waitForExistence(timeout: 3))

        // Navigate to another tab and back to verify the expense persists
        app.tabBars.buttons["Reports"].tap()
        sleep(1)
        app.tabBars.buttons["Expenses"].tap()

        // Verify the recurring expense is still visible after returning to the Expenses tab
        XCTAssertTrue(app.staticTexts["Persistent Recurring"].waitForExistence(timeout: 5),
                       "Recurring expense should persist when switching tabs")
        XCTAssertTrue(app.staticTexts["Recurring"].waitForExistence(timeout: 3),
                       "Recurring section header should still be visible")
    }
}
