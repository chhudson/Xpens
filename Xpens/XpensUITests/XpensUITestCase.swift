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
