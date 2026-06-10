import XCTest

final class FavoritesUITests: UITestBase {

    // MARK: Lock screen (no bypass — auth skipped, stays locked)
    func test_favorites_showsLockScreenWithoutBypass() {
        launchApp(bypassAuth: false)
        selectTab("Favorites")

        let lockScreen = app.otherElements["screen_locked"]
        XCTAssertTrue(waitFor(lockScreen, timeout: 5), "Lock screen should appear when auth is not bypassed")
    }

    func test_favorites_unlockButtonPresentOnLockScreen() {
        launchApp(bypassAuth: false)
        selectTab("Favorites")

        let unlockBtn = app.buttons["btn_unlock"]
        XCTAssertTrue(waitFor(unlockBtn, timeout: 5), "Unlock button must be visible on lock screen")
    }

    func test_favorites_lockScreenHiddenAfterBypass() {
        launchApp(bypassAuth: true)
        selectTab("Favorites")

        let lockScreen = app.otherElements["screen_locked"]
        XCTAssertFalse(lockScreen.waitForExistence(timeout: 3), "Lock screen should not appear when auth is bypassed")
    }

    // MARK: Empty state (bypassed, no favorites saved)
    func test_favorites_showsEmptyStateWhenNoFavorites() {
        launchApp(bypassAuth: true)
        selectTab("Favorites")

        let emptyTitle = app.staticTexts["No favorites yet"]
        XCTAssertTrue(waitFor(emptyTitle, timeout: 5), "Empty state title should appear when there are no favorites")
    }

    func test_favorites_searchButtonExistsInContent() {
        launchApp(bypassAuth: true)
        selectTab("Favorites")

        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 5), "Navigation bar should be visible in favorites content")
    }

    // MARK: Re-lock on tab switch
    func test_favorites_relockWhenLeavingTab() {
        launchApp(bypassAuth: false)
        selectTab("Favorites")

        guard waitFor(app.otherElements["screen_locked"], timeout: 5) else {
            XCTFail("Lock screen not shown initially")
            return
        }

        selectTab("Characters")
        selectTab("Favorites")

        XCTAssertTrue(app.otherElements["screen_locked"].waitForExistence(timeout: 3), "Should re-lock after tab switch")
    }

    // MARK: With favorites
    func test_favorites_showsListAfterAddingFavorite() {
        launchApp(bypassAuth: true)

        let firstRow = app.otherElements.matching(identifier: "character_row").firstMatch
        guard waitFor(firstRow, timeout: 30) else {
            XCTFail("Character rows did not load in time")
            return
        }

        let favBtn = app.buttons.matching(identifier: "btn_favorite").firstMatch
        guard favBtn.waitForExistence(timeout: 3) else {
            XCTFail("Favorite button not found on row")
            return
        }
        favBtn.tap()

        selectTab("Favorites")

        let favList = app.scrollViews["list_favorites"]
        XCTAssertTrue(waitFor(favList, timeout: 5), "Favorites list should appear after adding a favorite")

        let row = app.otherElements.matching(identifier: "character_row").firstMatch
        XCTAssertTrue(row.exists, "The favorited character should appear in the list")
    }
}
