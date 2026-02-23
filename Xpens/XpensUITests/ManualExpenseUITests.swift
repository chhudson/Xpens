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

        // Fill in amount
        let amountField = app.textFields["manual-entry-amount"]
        XCTAssertTrue(amountField.exists)
        amountField.tap()
        amountField.typeText("12.50")

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

        // Scroll down to find tags section if needed
        let newTagButton = app.buttons["tag-picker-new"]
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
