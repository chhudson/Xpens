import XCTest

final class ScreenshotTests: XpensUITestCase {

    private var screenshotDir: String {
        let home = ProcessInfo.processInfo.environment["HOME"] ?? "/tmp"
        return "\(home)/Desktop/XpensScreenshots"
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments = [
            "--uitesting-reset",
            "--uitesting-skip-onboarding",
            "--uitesting-seed-screenshots"
        ]
        app.launch()

        // Wait for app to fully load
        XCTAssertTrue(app.navigationBars["Expenses"].waitForExistence(timeout: 10))
    }

    func testCaptureAllScreenshots() throws {
        // 1. Expense list (main screen with sample data)
        sleep(1) // let list render fully
        saveScreenshot(name: "01_ExpenseList")

        // 2. Manual entry form
        let addButton = app.buttons["expense-list-add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let merchantField = app.textFields["manual-entry-merchant"]
        XCTAssertTrue(merchantField.waitForExistence(timeout: 5))
        merchantField.tap()
        merchantField.typeText("Whole Foods Market")

        let amountField = app.textFields["manual-entry-amount"]
        amountField.tap()
        amountField.typeText("42.85")

        sleep(1)
        saveScreenshot(name: "02_ManualEntry")

        // Dismiss the form
        app.buttons["manual-entry-cancel"].tap()

        // 3. Reports tab
        let reportsTab = app.tabBars.buttons["Reports"]
        XCTAssertTrue(reportsTab.waitForExistence(timeout: 5))
        reportsTab.tap()
        XCTAssertTrue(app.navigationBars["Reports"].waitForExistence(timeout: 5))
        sleep(1) // let charts render
        saveScreenshot(name: "03_Reports")

        // 4. Settings tab
        let settingsTab = app.tabBars.buttons["Settings"]
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 5))
        sleep(1)
        saveScreenshot(name: "04_Settings")

        // 5. Manage Categories (from Settings)
        app.staticTexts["Manage Categories"].tap()
        XCTAssertTrue(app.navigationBars["Categories"].waitForExistence(timeout: 5))
        sleep(1)
        saveScreenshot(name: "05_Categories")

        // Go back to Settings
        app.navigationBars.buttons.element(boundBy: 0).tap()

        // 6. Back to Expenses tab and open Add Expense tab (camera/OCR entry point)
        let addTab = app.tabBars.buttons["Add Expense"]
        XCTAssertTrue(addTab.waitForExistence(timeout: 5))
        addTab.tap()
        sleep(1)
        saveScreenshot(name: "06_AddExpense")
    }

    // MARK: - Helpers

    private func saveScreenshot(name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
