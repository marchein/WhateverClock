import SwiftUI
import Combine
import WidgetKit

/// Shared UserDefaults suite used by both the app and the widget extension.
private let appGroupStore = UserDefaults(suiteName: "group.de.marc-hein.WhateverClock")

/**
 `SettingsModel` stores and manages user settings for WhateverClock, with automatic persistence using `@AppStorage`.
 
 Settings are written to a shared App Group UserDefaults container so that the widget
 extension can read them without any additional synchronisation.
 
 Provides convenience methods for color manipulation and resetting settings to default values.
 Designed for use as an observable object in the application's settings workflow.
 */
final class SettingsModel: ObservableObject {
    /// Hex string representing the clock face color. Persisted via AppStorage.
    @AppStorage("clockFaceColor", store: appGroupStore) var clockFaceColorHex: String = Color.white.hex
    /// Hex string representing the number color. Persisted via AppStorage.
    @AppStorage("numberColor", store: appGroupStore) var numberColorHex: String = Color.black.hex
    /// Hex string representing the index color. Persisted via AppStorage.
    @AppStorage("indexColor", store: appGroupStore) var indexColorHex: String = Color.black.hex
    /// Hex string representing the hands color. Persisted via AppStorage.
    @AppStorage("handsColor", store: appGroupStore) var handsColorHex: String = Color.black.hex
    /// Hex string representing the seconds hand color. Persisted via AppStorage.
    @AppStorage("secondsColor", store: appGroupStore) var secondsColorHex: String = Color.red.hex
    /// Boolean value that couples index and number color. Persisted via AppStorage.
    @AppStorage("coupleIndexNumberColor", store: appGroupStore) var coupleIndexNumberColor: Bool = true
    /// Double value representing clock size. Persisted via AppStorage.
    @AppStorage("clockSize", store: appGroupStore) var clockSize: Double = 320
    /// Boolean value for seconds hand visibility. Persisted via AppStorage.
    @AppStorage("showSeconds", store: appGroupStore) var showSeconds: Bool = true
    /// Boolean value for milliseconds hand visibility. Persisted via AppStorage.
    @AppStorage("showMilliseconds", store: appGroupStore) var showMilliseconds: Bool = false
    /// Boolean value for 24-hour display. Persisted via AppStorage.
    @AppStorage("show24h", store: appGroupStore) var show24h: Bool = true

    /// Cancellable for observing settings changes and triggering widget reloads.
    private var widgetReloadCancellable: AnyCancellable?

    init() {
        // Reload the widget timeline whenever any setting changes so the widget
        // always reflects the latest appearance.
        widgetReloadCancellable = objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { _ in
                // Execute after the current change is committed.
                DispatchQueue.main.async {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
    }

    /**
     Converts a hex string to a `Color` object.
     
     - Parameter hex: The hex string representing the color.
     - Returns: The corresponding `Color`.
     */
    func color(from hex: String) -> Color { Color(hex: hex) }

    /**
     Sets the number color and, if coupled, the index color as well.
     
     - Parameter color: The new `Color` for numbers (and indexes if coupled).
     */
    func setNumberColor(_ color: Color) {
        numberColorHex = color.hex
        if coupleIndexNumberColor { indexColorHex = color.hex }
    }

    /**
     Sets the index color independently.
     
     - Parameter color: The new `Color` for indexes.
     */
    func setIndexColor(_ color: Color) { indexColorHex = color.hex }

    /**
     Sets the clock face color.
     
     - Parameter color: The new `Color` for the clock face.
     */
    func setClockFaceColor(_ color: Color) { clockFaceColorHex = color.hex }
    
    /**
     Sets the seconds hand color.
     
     - Parameter color: The new `Color` for the seconds hand.
     */
    func setSecondsColor(_ color: Color) { secondsColorHex = color.hex }

    /**
     Resets only the design-related settings to default values.
     */
    func resetDesign() {
        clockFaceColorHex = Color.white.hex
        numberColorHex = Color.black.hex
        indexColorHex = Color.black.hex
        handsColorHex = Color.gray.hex
        secondsColorHex = Color.red.hex
        coupleIndexNumberColor = true
    }

    /**
     Resets all settings to default values, including design and functional options.
     */
    func resetAll() {
        resetDesign()
        clockSize = 320
        showSeconds = true
        showMilliseconds = false
        show24h = true
    }
}
