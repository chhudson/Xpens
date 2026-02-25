import XCTest

final class TipJarUITests: XpensUITestCase {

    func testTipJarShowsProducts() throws {
        launchSeededApp()

        // Navigate to Settings
        XCTAssertTrue(app.navigationBars["Expenses"].waitForExistence(timeout: 5))
        app.tabBars.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3))

        // Tap Tip Jar row
        let tipJarRow = app.staticTexts["Tip Jar"]
        XCTAssertTrue(tipJarRow.waitForExistence(timeout: 3))
        tipJarRow.tap()

        // Verify Tip Jar screen loads
        XCTAssertTrue(app.navigationBars["Tip Jar"].waitForExistence(timeout: 5))

        // Verify products load (not stuck on spinner)
        // The tip buttons should contain the product names
        let coffeeButton = app.staticTexts["Coffee"]
        XCTAssertTrue(coffeeButton.waitForExistence(timeout: 10),
                       "Tip products should load — if stuck on spinner, StoreKit config may not be linked in scheme")

        // Verify all three tips are visible
        XCTAssertTrue(app.staticTexts["Lunch"].exists)
        XCTAssertTrue(app.staticTexts["Dinner"].exists)

        // Verify prices are displayed
        XCTAssertTrue(app.staticTexts["$0.99"].exists)
        XCTAssertTrue(app.staticTexts["$4.99"].exists)
        XCTAssertTrue(app.staticTexts["$9.99"].exists)
    }
}
