import XCTest

final class OnboardingUITests: XpensUITestCase {

    func testCompleteOnboardingFlow() throws {
        launchFreshApp()

        // Page 1: Welcome — tap Next
        let nextButton = app.buttons["onboarding-next"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 5))
        nextButton.tap()

        // Page 2: Currency — USD is pre-selected, tap Next
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
        XCTAssertTrue(app.staticTexts["USD"].waitForExistence(timeout: 3))

        // Advance to Page 3: Featured Categories
        app.buttons["onboarding-next"].tap()
        XCTAssertTrue(app.staticTexts["Pick 4 Quick Categories"].waitForExistence(timeout: 3))
    }
}
