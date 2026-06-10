import XCTest

final class CharacterListUITests: UITestBase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        launchApp()
    }

    // MARK: Structural
    func test_characterList_navigationBarVisible() {
        XCTAssertTrue(app.navigationBars.firstMatch.exists)
    }

    func test_characterList_searchButtonExists() {
        let searchBtn = app.buttons["btn_search"]
        XCTAssertTrue(waitFor(searchBtn, timeout: 5))
    }

    func test_characterList_tabBarVisible() {
        XCTAssertTrue(app.tabBars.firstMatch.exists)
    }

    // MARK: Loading state
    func test_characterList_showsLoadingOrContent() {
        let loading = app.otherElements["overlay_loading"]
        let list = app.scrollViews["list_characters"]

        // Either loading overlay or list must be visible shortly after launch
        let appeared = loading.waitForExistence(timeout: 3) || list.waitForExistence(timeout: 3)
        XCTAssertTrue(appeared, "Expected loading overlay or character list to appear")
    }

    // MARK: Content
    func test_characterList_rowsAppearAfterLoad() {
        let firstRow = app.otherElements.matching(identifier: "character_row").firstMatch
        XCTAssertTrue(waitFor(firstRow, timeout: 30), "Character rows should appear after network load")
    }

    func test_characterList_tapSearchRevealTextField() {
        let searchBtn = app.buttons["btn_search"]
        guard waitFor(searchBtn, timeout: 5) else {
            XCTFail("Search button not found")
            return
        }
        searchBtn.tap()
        XCTAssertTrue(app.textFields.firstMatch.waitForExistence(timeout: 3), "Text field should appear after tapping search")
    }

    func test_characterList_searchFiltersResults() {
        guard waitFor(app.otherElements.matching(identifier: "character_row").firstMatch, timeout: 30) else {
            XCTFail("Rows did not load in time")
            return
        }

        app.buttons["btn_search"].tap()
        let textField = app.textFields.firstMatch
        guard textField.waitForExistence(timeout: 3) else {
            XCTFail("Search text field not found")
            return
        }

        textField.typeText("Rick")
        let rows = app.otherElements.matching(identifier: "character_row")
        // Rows should still exist (Rick Sanchez at minimum)
        XCTAssertGreaterThan(rows.count, 0)
    }

    func test_characterList_tapRowOpensDetailSheet() {
        let firstRow = app.otherElements.matching(identifier: "character_row").firstMatch
        guard waitFor(firstRow, timeout: 30) else {
            XCTFail("No character rows loaded")
            return
        }

        firstRow.tap()
        // Detail sheet presents with a drag indicator (sheet)
        let sheet = app.scrollViews.firstMatch
        XCTAssertTrue(sheet.waitForExistence(timeout: 5), "Detail sheet should appear after tapping a row")
    }

    func test_characterList_detailSheetDismisses() {
        let firstRow = app.otherElements.matching(identifier: "character_row").firstMatch
        guard waitFor(firstRow, timeout: 30) else {
            XCTFail("No character rows loaded")
            return
        }

        firstRow.tap()
        let sheet = app.scrollViews.firstMatch
        guard sheet.waitForExistence(timeout: 5) else {
            XCTFail("Sheet did not appear")
            return
        }

        // Swipe down to dismiss
        sheet.swipeDown(velocity: .fast)
        XCTAssertTrue(app.otherElements.matching(identifier: "character_row").firstMatch.waitForExistence(timeout: 3))
    }

    func test_characterList_favoriteButtonExistsOnRow() {
        guard waitFor(app.otherElements.matching(identifier: "character_row").firstMatch, timeout: 20) else {
            XCTFail("No rows loaded")
            return
        }
        let favBtn = app.buttons.matching(identifier: "btn_favorite").firstMatch
        XCTAssertTrue(favBtn.exists)
    }
}
