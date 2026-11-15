import XCTest

/// End-to-end tests of the main screen and the settings sheet.
final class WhateverClockUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-settings", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
    }

    override func tearDownWithError() throws {
        XCUIDevice.shared.orientation = .portrait
        app = nil
    }

    // MARK: - Helpers

    private var digitalClock: XCUIElement { app.staticTexts["digitalClock"] }

    private func openSettings() {
        let button = app.buttons["openSettingsButton"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.tap()
        XCTAssertTrue(app.switches["toggle24h"].waitForExistence(timeout: 5))
    }

    private func closeSettings() {
        app.buttons["doneButton"].tap()
        XCTAssertTrue(app.switches["toggle24h"].waitForNonExistence(timeout: 5))
    }

    private func toggle(_ id: String) -> XCUIElement { app.switches[id] }

    private func isOn(_ element: XCUIElement) -> Bool { (element.value as? String) == "1" }

    /// Taps the actual switch control (tapping the row label is unreliable on some iOS versions).
    private func flip(_ id: String) {
        let element = toggle(id)
        let before = isOn(element)
        let control = element.switches.firstMatch.exists ? element.switches.firstMatch : element
        control.tap()
        if isOn(element) == before {
            element.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5)).tap()
        }
        XCTAssertNotEqual(isOn(element), before, "\(id) did not change")
    }

    private func setToggle(_ id: String, _ on: Bool) {
        if isOn(toggle(id)) != on { flip(id) }
    }

    private var digitalText: String { digitalClock.label }

    private func colonCount(_ text: String) -> Int { text.filter { $0 == ":" }.count }

    // MARK: - Main screen

    func testMainScreenShowsBothClocksAndSettingsButton() {
        XCTAssertTrue(app.otherElements["analogClock"].waitForExistence(timeout: 5)
                      || app.images["analogClock"].exists
                      || app.descendants(matching: .any)["analogClock"].exists)
        XCTAssertTrue(digitalClock.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["openSettingsButton"].exists)
        XCTAssertTrue(app.navigationBars["WhateverClock"].exists)
    }

    func testAnalogClockIsAccessible() {
        let clock = app.descendants(matching: .any)["analogClock"]
        XCTAssertTrue(clock.waitForExistence(timeout: 5))
        XCTAssertEqual(clock.label, "Analog clock")
        XCTAssertFalse((clock.value as? String ?? "").isEmpty, "Analog clock should expose the time as its value")
    }

    func testDefaultDigitalFormatIs24hWithSeconds() {
        XCTAssertTrue(digitalClock.waitForExistence(timeout: 5))
        let text = digitalText
        XCTAssertEqual(colonCount(text), 2, "Expected HH:mm:ss, got \(text)")
        XCTAssertFalse(text.contains("AM") || text.contains("PM"))
        XCTAssertFalse(text.contains("."))
    }

    func testDigitalClockAdvances() {
        XCTAssertTrue(digitalClock.waitForExistence(timeout: 5))
        let first = digitalText
        let changed = NSPredicate { _, _ in self.digitalText != first }
        expectation(for: changed, evaluatedWith: nil)
        waitForExpectations(timeout: 3)
    }

    // MARK: - Settings: display options

    func testSettingsSheetOpensAndCloses() {
        openSettings()
        XCTAssertTrue(app.navigationBars["Settings"].exists)
        closeSettings()
        XCTAssertTrue(digitalClock.exists)
    }

    func testSwipeDownDismissesSettings() {
        openSettings()
        let bar = app.navigationBars["Settings"]
        let start = bar.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        start.press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.95)))
        XCTAssertTrue(toggle("toggle24h").waitForNonExistence(timeout: 5))
    }

    func testTwelveHourFormat() {
        openSettings()
        flip("toggle24h")
        closeSettings()
        let text = digitalText
        XCTAssertTrue(text.hasSuffix("AM") || text.hasSuffix("PM"), "Expected AM/PM suffix, got \(text)")
    }

    func testHidingSecondsShowsHoursAndMinutesOnly() {
        openSettings()
        flip("toggleSeconds")
        closeSettings()
        XCTAssertEqual(colonCount(digitalText), 1, "Expected HH:mm, got \(digitalText)")
    }

    func testMillisecondsToggleDependsOnSeconds() {
        openSettings()
        XCTAssertTrue(toggle("toggleMilliseconds").isEnabled)
        flip("toggleSeconds")
        XCTAssertFalse(toggle("toggleMilliseconds").isEnabled)
        flip("toggleSeconds")
        XCTAssertTrue(toggle("toggleMilliseconds").isEnabled)
    }

    func testMillisecondsAreShown() {
        openSettings()
        flip("toggleMilliseconds")
        closeSettings()
        let text = digitalText
        XCTAssertTrue(text.contains("."), "Expected fractional seconds, got \(text)")
        XCTAssertEqual(colonCount(text), 2)
    }

    func testTwelveHourWithMillisecondsFitsOnScreen() {
        openSettings()
        flip("toggle24h")
        flip("toggleMilliseconds")
        closeSettings()
        let frame = digitalClock.frame
        let window = app.windows.firstMatch.frame
        XCTAssertTrue(window.contains(frame), "Digital clock \(frame) overflows window \(window)")
        XCTAssertTrue(digitalText.contains(".") && (digitalText.hasSuffix("AM") || digitalText.hasSuffix("PM")))
    }

    // MARK: - Settings: design

    func testAllColorPickersExist() {
        openSettings()
        for id in ["pickerDialColor", "pickerNumberColor", "pickerHandsColor", "pickerSecondsColor"] {
            XCTAssertTrue(app.descendants(matching: .any)[id].exists, "\(id) missing")
        }
        XCTAssertFalse(app.descendants(matching: .any)["pickerIndexColor"].exists)
    }

    func testDecouplingColorsRevealsIndexColorPicker() {
        openSettings()
        let indexPicker = app.descendants(matching: .any)["pickerIndexColor"]
        flip("toggleCoupleColors")
        XCTAssertTrue(indexPicker.waitForExistence(timeout: 3))
        flip("toggleCoupleColors")
        XCTAssertTrue(indexPicker.waitForNonExistence(timeout: 3))
    }

    func testColorPickerOpens() {
        openSettings()
        let picker = app.descendants(matching: .any)["pickerDialColor"]
        XCTAssertTrue(picker.exists)
        picker.coordinate(withNormalizedOffset: CGVector(dx: 0.95, dy: 0.5)).tap()
        // The system color picker is presented in its own sheet.
        let presented = app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS[c] 'Colors' OR identifier CONTAINS[c] 'color'")).firstMatch
        XCTAssertTrue(presented.waitForExistence(timeout: 5))
    }

    // MARK: - Settings: about & reset

    func testAppVersionIsShown() {
        openSettings()
        let version = app.staticTexts["appVersionValue"]
        if !version.exists { app.swipeUp() }
        XCTAssertTrue(version.waitForExistence(timeout: 3))
        XCTAssertTrue(version.label.contains("Build"), "Unexpected version label: \(version.label)")
    }

    func testResetDesignRestoresCoupling() {
        openSettings()
        flip("toggleCoupleColors")
        flip("toggle24h")
        app.swipeUp()
        app.buttons["resetDesignButton"].tap()
        app.swipeDown()
        XCTAssertTrue(isOn(toggle("toggleCoupleColors")))
        XCTAssertFalse(isOn(toggle("toggle24h")), "Reset design must not touch display options")
    }

    func testResetAllCanBeCancelled() {
        openSettings()
        flip("toggle24h")
        app.swipeUp()
        app.buttons["resetAllButton"].tap()
        let cancel = app.alerts.buttons["Cancel"]
        XCTAssertTrue(cancel.waitForExistence(timeout: 3))
        cancel.tap()
        app.swipeDown()
        XCTAssertFalse(isOn(toggle("toggle24h")))
    }

    func testResetAllRestoresDefaults() {
        openSettings()
        flip("toggle24h")
        flip("toggleMilliseconds")
        flip("toggleSeconds")
        flip("toggleCoupleColors")
        app.swipeUp()
        app.buttons["resetAllButton"].tap()
        let confirm = app.alerts.buttons["Reset"]
        XCTAssertTrue(confirm.waitForExistence(timeout: 3))
        confirm.tap()
        app.swipeDown()
        XCTAssertTrue(isOn(toggle("toggle24h")))
        XCTAssertTrue(isOn(toggle("toggleSeconds")))
        XCTAssertFalse(isOn(toggle("toggleMilliseconds")))
        XCTAssertTrue(isOn(toggle("toggleCoupleColors")))
    }

    // MARK: - Persistence

    func testSettingsPersistAcrossRelaunch() {
        openSettings()
        flip("toggle24h")
        flip("toggleSeconds")
        closeSettings()

        app.terminate()
        app.launchArguments = ["--uitesting", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()

        XCTAssertTrue(digitalClock.waitForExistence(timeout: 5))
        let text = digitalText
        XCTAssertEqual(colonCount(text), 1, "Expected h:mm a, got \(text)")
        XCTAssertTrue(text.hasSuffix("AM") || text.hasSuffix("PM"))
    }

    // MARK: - Layout

    func testLandscapeShowsBothClocks() {
        XCUIDevice.shared.orientation = .landscapeLeft
        let analog = app.descendants(matching: .any)["analogClock"]
        XCTAssertTrue(analog.waitForExistence(timeout: 5))
        XCTAssertTrue(digitalClock.exists)
        let window = app.windows.firstMatch.frame
        XCTAssertTrue(window.contains(digitalClock.frame))
        XCTAssertGreaterThan(analog.frame.width, 100)
        XCTAssertTrue(app.buttons["openSettingsButton"].isHittable)
    }
}
