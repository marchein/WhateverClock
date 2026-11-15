import XCTest

/// Verifies the German localization of the main UI.
final class LocalizationUITests: XCTestCase {
    func testGermanSettingsScreen() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-settings", "-AppleLanguages", "(de)", "-AppleLocale", "de_DE"]
        app.launch()

        let button = app.buttons["openSettingsButton"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        XCTAssertEqual(button.label, "Einstellungen öffnen")
        button.tap()

        XCTAssertTrue(app.navigationBars["Einstellungen"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.switches["24-Stunden-Anzeige"].exists || app.switches["toggle24h"].label.contains("24"))
        XCTAssertTrue(app.staticTexts["Sekunden anzeigen"].exists || app.switches["Sekunden anzeigen"].exists)
        XCTAssertTrue(app.buttons["Fertig"].exists || app.buttons["doneButton"].label == "Fertig")
    }
}
