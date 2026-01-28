//
//  DigitalClockView.swift
//  WhateverClock
//
//  Created by Marc Hein on 26.01.26.
//

import SwiftUI

/**
 Digital clock, format and text color configurable.
 
 - Parameters:
    - date: Current time to display.
    - showSeconds: Show seconds if true.
    - showMilliseconds: Show milliseconds if true. Only relevant if showSeconds is also true.
    - show24h: Use 24h or 12h format.
    - textColor: Color for clock text.
 */
struct DigitalClockView: View {
    /// The date to display in the clock.
    let date: Date
    /// Whether to show seconds in the clock.
    let showSeconds: Bool
    /// Whether to show milliseconds in the clock. Only relevant if showSeconds is true.
    let showMilliseconds: Bool
    /// Whether to use 24-hour time format.
    let show24h: Bool
    /// Color for the digital clock text.
    let textColor: Color
    
    var body: some View {
        Text(dateString(from: date))
            .font(.system(size: 47, weight: .semibold, design: .monospaced))
            .foregroundColor(textColor)
            .shadow(radius: 4)
            .accessibilityLabel(dateString(from: date))
    }
    
    /**
     Formats the date display as a string according to configuration.
     
     - Parameter date: The `Date` to format.
     - Returns: A formatted time string, optionally including seconds and milliseconds, and using either 24h or 12h format.
     */
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        let showMs = showSeconds && showMilliseconds
        if show24h {
            formatter.dateFormat = showMs ? "HH:mm:ss.SS" : (showSeconds ? "HH:mm:ss" : "HH:mm")
        } else {
            formatter.dateFormat = showMs ? "h:mm:ss.SS a" : (showSeconds ? "h:mm:ss a" : "h:mm a")
        }
        return formatter.string(from: date)
    }
}
