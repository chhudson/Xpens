import XCTest

final class ReportsUITests: XpensUITestCase {

    func testReportsScreenLoads() throws {
        launchSeededApp()

        // Wait for the app to fully load (Expenses tab is the default)
        XCTAssertTrue(app.navigationBars["Expenses"].waitForExistence(timeout: 5))

        // Navigate to Reports tab
        let reportsTab = app.tabBars.buttons["Reports"]
        XCTAssertTrue(reportsTab.waitForExistence(timeout: 5))
        reportsTab.tap()

        // Verify Reports screen elements
        XCTAssertTrue(app.navigationBars["Reports"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Date Range"].waitForExistence(timeout: 3))
    }

    func testReportsWithExpenseShowsData() throws {
        launchSeededApp()

        // First add an expense so there's data
        app.buttons["expense-list-add"].tap()
        let merchantField = app.textFields["manual-entry-merchant"]
        XCTAssertTrue(merchantField.waitForExistence(timeout: 3))
        merchantField.tap()
        merchantField.typeText("Chart Test")
        app.textFields["manual-entry-amount"].tap()
        app.textFields["manual-entry-amount"].typeText("100.00")
        app.buttons["manual-entry-save"].tap()

        // Wait for sheet to dismiss
        XCTAssertTrue(app.staticTexts["Chart Test"].waitForExistence(timeout: 3))

        // Navigate to Reports tab
        app.buttons["tab-reports"].tap()

        // Verify total amount is displayed
        let totalAmount = app.staticTexts["reports-total-amount"]
        XCTAssertTrue(totalAmount.waitForExistence(timeout: 3))

        // Verify View Full Report link exists
        XCTAssertTrue(app.staticTexts["View Full Report"].waitForExistence(timeout: 3))
    }
}
