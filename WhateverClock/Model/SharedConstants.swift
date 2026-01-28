//
//  SharedConstants.swift
//  WhateverClock
//
//  Created by GitHub Copilot on 28.01.26.
//

import Foundation

/**
 `SharedConstants` defines constants shared between the main app and widget extension.
 
 Contains the App Group identifier and UserDefaults keys for shared storage.
 */
enum SharedConstants {
    /// App Group identifier for sharing data between app and widget.
    static let appGroupIdentifier = "group.de.marchein.WhateverClock"
    
    /// Shared UserDefaults suite for app group storage.
    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }
    
    // MARK: - UserDefaults Keys
    
    /// Key for clock face color hex string.
    static let clockFaceColorKey = "clockFaceColor"
    /// Key for number color hex string.
    static let numberColorKey = "numberColor"
    /// Key for index color hex string.
    static let indexColorKey = "indexColor"
    /// Key for hands color hex string.
    static let handsColorKey = "handsColor"
    /// Key for seconds color hex string.
    static let secondsColorKey = "secondsColor"
    /// Key for digital color hex string.
    static let digitalColorKey = "digitalColor"
    /// Key for coupling index and number color.
    static let coupleIndexNumberColorKey = "coupleIndexNumberColor"
    /// Key for clock size.
    static let clockSizeKey = "clockSize"
    /// Key for showing seconds.
    static let showSecondsKey = "showSeconds"
    /// Key for showing milliseconds.
    static let showMillisecondsKey = "showMilliseconds"
    /// Key for 24-hour format.
    static let show24hKey = "show24h"
}
