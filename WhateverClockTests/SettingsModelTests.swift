import Testing
import SwiftUI
@testable import WhateverClock

@Suite("Settings model", .serialized)
struct SettingsModelTests {
    private let suiteName: String
    private let store: UserDefaults

    init() {
        suiteName = "WhateverClockTests.\(UUID().uuidString)"
        store = UserDefaults(suiteName: suiteName)!
    }

    private func makeModel() -> SettingsModel { SettingsModel(store: store, reloadsWidgets: false) }

    @Test func startsWithDefaults() {
        let model = makeModel()
        #expect(model.clockFaceColorHex == "#FFFFFF")
        #expect(model.numberColorHex == "#000000")
        #expect(model.indexColorHex == "#000000")
        #expect(model.handsColorHex == "#000000")
        #expect(model.secondsColorHex == "#FF3B30")
        #expect(model.coupleIndexNumberColor)
        #expect(model.showSeconds)
        #expect(!model.showMilliseconds)
        #expect(model.show24h)
        #expect(model.appearance == .defaults)
    }

    @Test func persistsAcrossInstances() {
        let model = makeModel()
        model.show24h = false
        model.showSeconds = false
        model.showMilliseconds = true
        model.setClockFaceColor(Color(hex: "#112233"))
        model.setHandsColor(Color(hex: "#445566"))
        model.setSecondsColor(Color(hex: "#00FF00"))

        let reloaded = makeModel()
        #expect(!reloaded.show24h)
        #expect(!reloaded.showSeconds)
        #expect(reloaded.showMilliseconds)
        #expect(reloaded.clockFaceColorHex == "#112233")
        #expect(reloaded.handsColorHex == "#445566")
        #expect(reloaded.secondsColorHex == "#00FF00")
    }

    @Test func numberColorUpdatesIndexWhenCoupled() {
        let model = makeModel()
        model.setNumberColor(Color(hex: "#AA0000"))
        #expect(model.numberColorHex == "#AA0000")
        #expect(model.indexColorHex == "#AA0000")
    }

    @Test func numberColorLeavesIndexWhenDecoupled() {
        let model = makeModel()
        model.coupleIndexNumberColor = false
        model.setIndexColor(Color(hex: "#0000AA"))
        model.setNumberColor(Color(hex: "#AA0000"))
        #expect(model.indexColorHex == "#0000AA")
        #expect(model.appearance.effectiveIndexColorHex == "#0000AA")

        model.coupleIndexNumberColor = true
        #expect(model.appearance.effectiveIndexColorHex == "#AA0000")
    }

    @Test func millisecondsOnlyAvailableWithSeconds() {
        let model = makeModel()
        #expect(model.millisecondsAvailable)
        model.showSeconds = false
        #expect(!model.millisecondsAvailable)
    }

    @Test func resetDesignKeepsDisplayOptions() {
        let model = makeModel()
        model.setClockFaceColor(.blue)
        model.setNumberColor(.green)
        model.setHandsColor(.orange)
        model.setSecondsColor(.purple)
        model.coupleIndexNumberColor = false
        model.show24h = false
        model.showSeconds = false

        model.resetDesign()

        #expect(model.appearance.clockFaceColorHex == ClockAppearance.defaults.clockFaceColorHex)
        #expect(model.numberColorHex == "#000000")
        #expect(model.handsColorHex == "#000000")
        #expect(model.secondsColorHex == "#FF3B30")
        #expect(model.coupleIndexNumberColor)
        #expect(!model.show24h)
        #expect(!model.showSeconds)
    }

    @Test func resetAllRestoresEverything() {
        let model = makeModel()
        model.setClockFaceColor(.blue)
        model.show24h = false
        model.showSeconds = false
        model.showMilliseconds = true

        model.resetAll()

        #expect(model.appearance == .defaults)
        #expect(model.show24h)
        #expect(model.showSeconds)
        #expect(!model.showMilliseconds)
        #expect(makeModel().appearance == .defaults)
    }

    @Test func widgetReadsWhatAppWrites() {
        let model = makeModel()
        model.setClockFaceColor(Color(hex: "#101010"))
        model.coupleIndexNumberColor = false
        model.setIndexColor(Color(hex: "#202020"))
        model.showSeconds = false

        let widget = ClockAppearance(store: store)
        #expect(widget.clockFaceColorHex == "#101010")
        #expect(widget.effectiveIndexColorHex == "#202020")
        #expect(!widget.showSeconds)
    }

    @Test func appearanceFallsBackForCorruptValues() {
        store.set("not a bool", forKey: ClockSettings.Key.showSeconds)
        store.set(42, forKey: ClockSettings.Key.clockFaceColor)
        let appearance = ClockAppearance(store: store)
        #expect(appearance.showSeconds == ClockSettings.Defaults.showSeconds)
        #expect(appearance.clockFaceColorHex == ClockSettings.Defaults.clockFaceColorHex)
    }

    @Test func uiTestingLaunchUsesIsolatedResettableStore() {
        let model = WhateverClockApp.makeSettings(arguments: ["app", "--uitesting", "--reset-settings"])
        #expect(model.appearance == .defaults)
        #expect(model.show24h)
    }
}
