import SwiftUI
import Combine
import WidgetKit

/**
 `SettingsModel` stores and manages user settings for WhateverClock.

 Values are persisted to a `UserDefaults` store, by default the shared App Group
 container, so the widget extension can read them (see `ClockAppearance`).
 */
final class SettingsModel: ObservableObject {
    private typealias K = ClockSettings.Key
    private typealias D = ClockSettings.Defaults

    @Published var clockFaceColorHex: String { didSet { persist(clockFaceColorHex, K.clockFaceColor) } }
    @Published var numberColorHex: String { didSet { persist(numberColorHex, K.numberColor) } }
    @Published var indexColorHex: String { didSet { persist(indexColorHex, K.indexColor) } }
    @Published var handsColorHex: String { didSet { persist(handsColorHex, K.handsColor) } }
    @Published var secondsColorHex: String { didSet { persist(secondsColorHex, K.secondsColor) } }
    @Published var coupleIndexNumberColor: Bool { didSet { persist(coupleIndexNumberColor, K.coupleIndexNumberColor) } }
    @Published var showSeconds: Bool { didSet { persist(showSeconds, K.showSeconds) } }
    @Published var showMilliseconds: Bool { didSet { persist(showMilliseconds, K.showMilliseconds) } }
    @Published var show24h: Bool { didSet { persist(show24h, K.show24h) } }

    private let store: UserDefaults
    private let reloadsWidgets: Bool
    private var widgetReloadTask: Task<Void, Never>?

    /**
     - Parameters:
        - store: Where settings are persisted. Defaults to the shared App Group store.
        - reloadsWidgets: Whether changes trigger a (debounced) widget timeline reload.
     */
    init(store: UserDefaults = ClockSettings.sharedStore, reloadsWidgets: Bool = true) {
        self.store = store
        self.reloadsWidgets = reloadsWidgets
        let appearance = ClockAppearance(store: store)
        clockFaceColorHex = appearance.clockFaceColorHex
        numberColorHex = appearance.numberColorHex
        indexColorHex = appearance.indexColorHex
        handsColorHex = appearance.handsColorHex
        secondsColorHex = appearance.secondsColorHex
        coupleIndexNumberColor = appearance.coupleIndexNumberColor
        showSeconds = appearance.showSeconds
        showMilliseconds = store.object(forKey: K.showMilliseconds) as? Bool ?? D.showMilliseconds
        show24h = store.object(forKey: K.show24h) as? Bool ?? D.show24h
    }

    /// Snapshot of the current appearance, identical to what the widget reads.
    var appearance: ClockAppearance { ClockAppearance(store: store) }

    /// Whether the milliseconds option has any effect (requires seconds).
    var millisecondsAvailable: Bool { showSeconds }

    /// Converts a hex string to a `Color`.
    func color(from hex: String) -> Color { Color(hex: hex) }

    /// Sets the number color and, if coupled, the index color as well.
    func setNumberColor(_ color: Color) {
        numberColorHex = color.hex
        if coupleIndexNumberColor { indexColorHex = color.hex }
    }

    func setIndexColor(_ color: Color) { indexColorHex = color.hex }
    func setClockFaceColor(_ color: Color) { clockFaceColorHex = color.hex }
    func setHandsColor(_ color: Color) { handsColorHex = color.hex }
    func setSecondsColor(_ color: Color) { secondsColorHex = color.hex }

    /// Resets only the design-related settings to default values.
    func resetDesign() {
        clockFaceColorHex = D.clockFaceColorHex
        numberColorHex = D.numberColorHex
        indexColorHex = D.indexColorHex
        handsColorHex = D.handsColorHex
        secondsColorHex = D.secondsColorHex
        coupleIndexNumberColor = D.coupleIndexNumberColor
    }

    /// Resets all settings to default values, including design and functional options.
    func resetAll() {
        resetDesign()
        showSeconds = D.showSeconds
        showMilliseconds = D.showMilliseconds
        show24h = D.show24h
    }

    private func persist(_ value: Any, _ key: String) {
        store.set(value, forKey: key)
        scheduleWidgetReload()
    }

    /// Debounced so dragging a color picker doesn't burn through the widget reload budget.
    private func scheduleWidgetReload() {
        guard reloadsWidgets else { return }
        widgetReloadTask?.cancel()
        widgetReloadTask = Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
