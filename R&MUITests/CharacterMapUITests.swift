import XCTest

final class CharacterMapUITests: UITestBase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        launchApp()
        selectTab("Map")
    }

    // MARK: Structural
    func test_map_mapViewExists() {
        let mapView = app.maps.firstMatch
        XCTAssertTrue(waitFor(mapView, timeout: 5), "Map view should be visible on Map tab")
    }

    func test_map_characterPanelVisible() {
        let panel = app.otherElements["panel_characters"]
        XCTAssertTrue(waitFor(panel, timeout: 5), "Character list panel should be visible")
    }

    func test_map_locationButtonExists() {
        let locBtn = app.buttons["btn_location"]
        XCTAssertTrue(waitFor(locBtn, timeout: 5), "Location button should be visible on map")
    }

    func test_map_tabBarRemainsVisibleWithPanel() {
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Tab bar must remain visible when panel is shown")
        XCTAssertTrue(waitFor(app.otherElements["panel_characters"], timeout: 5))
        XCTAssertTrue(app.tabBars.firstMatch.isHittable, "Tab bar must be hittable (not covered by panel)")
    }

    // MARK: Panel interactions
    func test_map_panelExpandsOnSwipeUp() {
        let panel = app.otherElements["panel_characters"]
        guard waitFor(panel, timeout: 5) else {
            XCTFail("Panel not found")
            return
        }

        let initialHeight = panel.frame.height

        // Tap the handle to expand. The handle has onTapGesture { isExpanded.toggle() }.
        // Try the named element first; fall back to top-of-panel coordinate.
        let handle = app.otherElements["panel_handle"]
        if handle.waitForExistence(timeout: 2) {
            handle.tap()
        } else {
            panel.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.02)).tap()
        }

        // Spring(response: 0.4, dampingFraction: 0.85) settles in ~1.5 s.
        // Wait 2 s to also let the accessibility tree reflect the new frame.
        Thread.sleep(forTimeInterval: 2.0)

        let expandedHeight = panel.frame.height
        XCTAssertGreaterThan(expandedHeight, initialHeight, "Panel should expand after tapping handle")
    }

    func test_map_panelMinimizesOnSwipeDown() {
        let panel = app.otherElements["panel_characters"]
        guard waitFor(panel, timeout: 5) else {
            XCTFail("Panel not found")
            return
        }

        dragPanelHandleArea(panel, dy: 150)

        let pill = app.buttons["btn_restore_pill"]
        XCTAssertTrue(waitFor(pill, timeout: 3), "Restore pill should appear after panel is minimized")
    }

    func test_map_pillRestoresPanelOnTap() {
        let panel = app.otherElements["panel_characters"]
        guard waitFor(panel, timeout: 5) else {
            XCTFail("Panel not found")
            return
        }

        dragPanelHandleArea(panel, dy: 150)

        let pill = app.buttons["btn_restore_pill"]
        guard waitFor(pill, timeout: 3) else {
            XCTFail("Restore pill did not appear")
            return
        }

        pill.tap()
        Thread.sleep(forTimeInterval: 0.5)

        XCTAssertTrue(waitFor(app.otherElements["panel_characters"], timeout: 3), "Panel should restore after tapping pill")
        XCTAssertFalse(pill.waitForExistence(timeout: 2), "Pill should disappear after panel is restored")
    }

    // MARK: Character rows
    func test_map_characterRowsAppearInPanel() {
        let panel = app.otherElements["panel_characters"]
        if waitFor(panel, timeout: 5) { expandPanel(panel) }

        let firstRow = app.buttons.matching(identifier: "map_character_row").firstMatch
        XCTAssertTrue(waitFor(firstRow, timeout: 25), "Character rows should appear in map panel after loading")
    }

    func test_map_tapPanelRowCentersMap() {
        let panel = app.otherElements["panel_characters"]
        if waitFor(panel, timeout: 5) { expandPanel(panel) }

        let firstRow = app.buttons.matching(identifier: "map_character_row").firstMatch
        guard waitFor(firstRow, timeout: 25) else {
            XCTFail("No rows loaded in map panel")
            return
        }

        firstRow.tap()
        XCTAssertTrue(app.maps.firstMatch.exists, "Map should still be visible after tapping a row")
    }

    func test_map_locationButtonTriggerPermission() {
        let locBtn = app.buttons["btn_location"]
        guard waitFor(locBtn, timeout: 5) else {
            XCTFail("Location button not found")
            return
        }

        locBtn.tap()

        let allowBtn = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'Allow'")).firstMatch
        if allowBtn.waitForExistence(timeout: 3) {
            allowBtn.tap()
        }

        XCTAssertTrue(app.maps.firstMatch.exists, "Map should still be visible after location button tap")
    }

    // MARK: Helpers

    /// Tap the handle to expand the panel (handle has onTapGesture { isExpanded.toggle() }).
    private func expandPanel(_ panel: XCUIElement) {
        let handle = app.otherElements["panel_handle"]
        if handle.waitForExistence(timeout: 2) {
            handle.tap()
        } else {
            panel.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.02)).tap()
        }
        Thread.sleep(forTimeInterval: 2.0)
    }

    /// Drag from handle area downward to minimize the panel.
    /// Downward drag works because the path stays within the panel / screen bottom — no Map gesture conflict.
    private func dragPanelHandleArea(_ panel: XCUIElement, dy: CGFloat) {
        let start = panel.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.02))
        let end = start.withOffset(CGVector(dx: 0, dy: dy))
        start.press(forDuration: 0.3, thenDragTo: end)
        Thread.sleep(forTimeInterval: 1.0)
    }
}
