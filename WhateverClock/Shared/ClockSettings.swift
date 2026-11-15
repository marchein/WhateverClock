//
//  ClockSettings.swift
//  WhateverClock
//
//  Shared between the app and the widget extension.
//

import SwiftUI

/// Identifiers, keys and default values shared by the app and the widget.
enum ClockSettings {
    /// App Group used to share settings between the app and the widget.
    static let appGroupIdentifier = "group.de.marc-hein.WhateverClock"

    /// The shared store. Falls back to `.standard` if the App Group is unavailable.
    static var sharedStore: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? .standard
    }

    enum Key {
        static let clockFaceColor = "clockFaceColor"
        static let numberColor = "numberColor"
        static let indexColor = "indexColor"
        static let handsColor = "handsColor"
        static let secondsColor = "secondsColor"
        static let coupleIndexNumberColor = "coupleIndexNumberColor"
        static let showSeconds = "showSeconds"
        static let showMilliseconds = "showMilliseconds"
        static let show24h = "show24h"
    }

    enum Defaults {
        static let clockFaceColorHex = "#FFFFFF"
        static let numberColorHex = "#000000"
        static let indexColorHex = "#000000"
        static let handsColorHex = "#000000"
        static let secondsColorHex = "#FF3B30"
        static let coupleIndexNumberColor = true
        static let showSeconds = true
        static let showMilliseconds = false
        static let show24h = true
    }
}

/// An immutable snapshot of the clock appearance, read from a `UserDefaults` store.
struct ClockAppearance: Equatable {
    var clockFaceColorHex: String
    var numberColorHex: String
    var indexColorHex: String
    var handsColorHex: String
    var secondsColorHex: String
    var coupleIndexNumberColor: Bool
    var showSeconds: Bool

    static let defaults = ClockAppearance(
        clockFaceColorHex: ClockSettings.Defaults.clockFaceColorHex,
        numberColorHex: ClockSettings.Defaults.numberColorHex,
        indexColorHex: ClockSettings.Defaults.indexColorHex,
        handsColorHex: ClockSettings.Defaults.handsColorHex,
        secondsColorHex: ClockSettings.Defaults.secondsColorHex,
        coupleIndexNumberColor: ClockSettings.Defaults.coupleIndexNumberColor,
        showSeconds: ClockSettings.Defaults.showSeconds
    )

    init(clockFaceColorHex: String, numberColorHex: String, indexColorHex: String,
         handsColorHex: String, secondsColorHex: String,
         coupleIndexNumberColor: Bool, showSeconds: Bool) {
        self.clockFaceColorHex = clockFaceColorHex
        self.numberColorHex = numberColorHex
        self.indexColorHex = indexColorHex
        self.handsColorHex = handsColorHex
        self.secondsColorHex = secondsColorHex
        self.coupleIndexNumberColor = coupleIndexNumberColor
        self.showSeconds = showSeconds
    }

    /// Reads the appearance from `store`, falling back to defaults for missing keys.
    init(store: UserDefaults) {
        typealias K = ClockSettings.Key
        typealias D = ClockSettings.Defaults
        self.init(
            clockFaceColorHex: store.object(forKey: K.clockFaceColor) as? String ?? D.clockFaceColorHex,
            numberColorHex: store.object(forKey: K.numberColor) as? String ?? D.numberColorHex,
            indexColorHex: store.object(forKey: K.indexColor) as? String ?? D.indexColorHex,
            handsColorHex: store.object(forKey: K.handsColor) as? String ?? D.handsColorHex,
            secondsColorHex: store.object(forKey: K.secondsColor) as? String ?? D.secondsColorHex,
            coupleIndexNumberColor: store.object(forKey: K.coupleIndexNumberColor) as? Bool ?? D.coupleIndexNumberColor,
            showSeconds: store.object(forKey: K.showSeconds) as? Bool ?? D.showSeconds
        )
    }

    /// The index color actually displayed, respecting the "couple colors" option.
    var effectiveIndexColorHex: String { coupleIndexNumberColor ? numberColorHex : indexColorHex }

    var faceColor: Color { Color(hex: clockFaceColorHex) }
    var numberColor: Color { Color(hex: numberColorHex) }
    var indexColor: Color { Color(hex: effectiveIndexColorHex) }
    var handsColor: Color { Color(hex: handsColorHex) }
    var secondsColor: Color { Color(hex: secondsColorHex) }
}
