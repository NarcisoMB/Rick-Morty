import XCTest

class UITestBase: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    /// Launch with splash skipped and biometric bypassed.
    func launchApp(bypassAuth: Bool = true) {
        app.launchEnvironment["UI_TESTING_SKIP_SPLASH"] = "1"
        // "1" = unlock immediately, "0" = stay locked (no real auth attempted)
        app.launchEnvironment["UI_TESTING_BYPASS_AUTH"] = bypassAuth ? "1" : "0"
        // Force English so tab labels are predictable regardless of persisted LanguageManager state.
        app.launchArguments += ["-app_language", "en"]
        app.launch()
    }

    /// Navigate to a tab by its label.
    func selectTab(_ label: String) {
        app.tabBars.firstMatch.buttons[label].tap()
    }

    @discardableResult
    func waitFor(_ element: XCUIElement, timeout: TimeInterval = 15) -> Bool {
        element.waitForExistence(timeout: timeout)
    }
}
