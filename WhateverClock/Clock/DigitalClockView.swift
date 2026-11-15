//
//  DigitalClockView.swift
//  WhateverClock
//
//  Created by Marc Hein on 26.01.26.
//

import SwiftUI

/**
 Digital clock, format configurable.

 - Parameters:
    - date: Current time to display.
    - showSeconds: Show seconds if true.
    - showMilliseconds: Show fractional seconds if true. Only relevant if showSeconds is also true.
    - show24h: Use 24h or 12h format.
 */
struct DigitalClockView: View {
    let date: Date
    let showSeconds: Bool
    let showMilliseconds: Bool
    let show24h: Bool

    var body: some View {
        let text = Self.string(from: date, showSeconds: showSeconds, showMilliseconds: showMilliseconds, show24h: show24h)
        Text(text)
            .font(.system(size: 47, weight: .semibold, design: .monospaced))
            .lineLimit(1)
            .minimumScaleFactor(0.4)
            .shadow(radius: 4)
            .padding(.horizontal)
            .accessibilityLabel(text)
            .accessibilityIdentifier("digitalClock")
    }

    /// The `DateFormatter` pattern for the given options.
    static func dateFormat(showSeconds: Bool, showMilliseconds: Bool, show24h: Bool) -> String {
        let showMs = showSeconds && showMilliseconds
        if show24h {
            return showMs ? "HH:mm:ss.SS" : (showSeconds ? "HH:mm:ss" : "HH:mm")
        } else {
            return showMs ? "h:mm:ss.SS a" : (showSeconds ? "h:mm:ss a" : "h:mm a")
        }
    }

    /// Formatters are expensive and this runs every frame, so they are cached per format/locale/time zone.
    private static var formatterCache: [String: DateFormatter] = [:]

    static func string(from date: Date, showSeconds: Bool, showMilliseconds: Bool, show24h: Bool,
                       locale: Locale = .autoupdatingCurrent, timeZone: TimeZone = .autoupdatingCurrent) -> String {
        let format = dateFormat(showSeconds: showSeconds, showMilliseconds: showMilliseconds, show24h: show24h)
        let key = "\(format)|\(locale.identifier)|\(timeZone.identifier)"
        let formatter: DateFormatter
        if let cached = formatterCache[key] {
            formatter = cached
        } else {
            formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = locale
            formatter.timeZone = timeZone
            formatterCache[key] = formatter
        }
        return formatter.string(from: date)
    }
}
