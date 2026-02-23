import XCTest

final class SettingsUITests: XpensUITestCase {

    func testSettingsScreenLoads() throws {
        launchSeededApp()

        // Wait for app to fully load
        XCTAssertTrue(app.navigationBars["Expenses"].waitForExistence(timeout: 5))

        // Navigate to Settings tab
        app.tabBars.buttons["Settings"].tap()

        // Verify Settings screen elements
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Default Currency"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Manage Categories"].exists)
        XCTAssertTrue(app.staticTexts["Manage Tags"].exists)
        XCTAssertTrue(app.staticTexts["Version"].exists)
    }

    func testNavigateToCurrencyPicker() throws {
        launchSeededApp()

        XCTAssertTrue(app.navigationBars["Expenses"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))

        // Tap currency row
        app.staticTexts["Default Currency"].tap()

        // Verify Currency picker screen
        XCTAssertTrue(app.navigationBars["Currency"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["USD"].waitForExistence(timeout: 3))
    }

    func testNavigateToManageCategories() throws {
        launchSeededApp()

        XCTAssertTrue(app.navigationBars["Expenses"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))

        // Tap manage categories
        app.staticTexts["Manage Categories"].tap()

        // Verify Categories screen with default categories
        XCTAssertTrue(app.navigationBars["Categories"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Food"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Hotel"].exists)
    }
}
