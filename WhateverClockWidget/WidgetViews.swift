//
//  WidgetViews.swift
//  WhateverClockWidget
//
//  Created by GitHub Copilot on 28.01.26.
//

import WidgetKit
import SwiftUI

/**
 Helper function to load widget settings from shared App Group storage.
 
 Reads all widget settings from the shared UserDefaults suite and provides
 appropriate default values when settings are not present.
 
 - Returns: A tuple containing all widget settings with default values.
 */
fileprivate func loadWidgetSettings() -> (
    clockFaceColor: String,
    numberColor: String,
    indexColor: String,
    handsColor: String,
    secondsColor: String,
    digitalColor: String,
    coupleIndexNumberColor: Bool,
    show24h: Bool
) {
    let defaults = SharedConstants.sharedDefaults ?? UserDefaults.standard
    
    // For bool values, we need to check if the key exists to provide proper defaults
    let coupleIndexNumberColorValue: Bool
    if defaults.object(forKey: SharedConstants.coupleIndexNumberColorKey) != nil {
        coupleIndexNumberColorValue = defaults.bool(forKey: SharedConstants.coupleIndexNumberColorKey)
    } else {
        coupleIndexNumberColorValue = true // Default value
    }
    
    let show24hValue: Bool
    if defaults.object(forKey: SharedConstants.show24hKey) != nil {
        show24hValue = defaults.bool(forKey: SharedConstants.show24hKey)
    } else {
        show24hValue = true // Default value
    }
    
    return (
        clockFaceColor: defaults.string(forKey: SharedConstants.clockFaceColorKey) ?? Color.white.hex,
        numberColor: defaults.string(forKey: SharedConstants.numberColorKey) ?? Color.black.hex,
        indexColor: defaults.string(forKey: SharedConstants.indexColorKey) ?? Color.black.hex,
        handsColor: defaults.string(forKey: SharedConstants.handsColorKey) ?? Color.black.hex,
        secondsColor: defaults.string(forKey: SharedConstants.secondsColorKey) ?? Color.red.hex,
        digitalColor: defaults.string(forKey: SharedConstants.digitalColorKey) ?? Color.black.hex,
        coupleIndexNumberColor: coupleIndexNumberColorValue,
        show24h: show24hValue
    )
}

/**
 Analog clock widget view displaying only the analog clock face.
 
 Reads settings from shared App Group storage and always hides the seconds hand.
 */
struct AnalogClockWidgetView: View {
    /// The timeline entry containing the date to display.
    let entry: ClockEntry
    
    /// Widget environment for family size.
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        let settings = loadWidgetSettings()
        
        ZStack {
            ClassicAnalogClockView(
                date: entry.date,
                showSeconds: false, // Always hide seconds in widgets
                numberColor: Color(hex: settings.numberColor),
                indexColor: Color(hex: settings.coupleIndexNumberColor ? settings.numberColor : settings.indexColor),
                faceColor: Color(hex: settings.clockFaceColor),
                handsColor: Color(hex: settings.handsColor),
                secondsColor: Color(hex: settings.secondsColor)
            )
        }
        .widgetBackground(Color.clear)
    }
}

/**
 Combined analog and digital clock widget view.
 
 Shows analog clock on the left side and digital time on the right side.
 Reads settings from shared App Group storage.
 */
struct AnalogDigitalClockWidgetView: View {
    /// The timeline entry containing the date to display.
    let entry: ClockEntry
    
    var body: some View {
        let settings = loadWidgetSettings()
        
        HStack(spacing: 8) {
            // Analog clock on the left
            ClassicAnalogClockView(
                date: entry.date,
                showSeconds: false, // Always hide seconds in widgets
                numberColor: Color(hex: settings.numberColor),
                indexColor: Color(hex: settings.coupleIndexNumberColor ? settings.numberColor : settings.indexColor),
                faceColor: Color(hex: settings.clockFaceColor),
                handsColor: Color(hex: settings.handsColor),
                secondsColor: Color(hex: settings.secondsColor)
            )
            .frame(maxWidth: .infinity)
            
            // Digital clock on the right
            VStack {
                Spacer()
                Text(formatTime(entry.date, show24h: settings.show24h))
                    .font(.system(size: 32, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(hex: settings.digitalColor))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(8)
        .widgetBackground(Color.clear)
    }
    
    /**
     Formats the time without seconds for widget display.
     
     - Parameters:
        - date: The date to format.
        - show24h: Whether to use 24-hour format.
     - Returns: Formatted time string without seconds.
     */
    private func formatTime(_ date: Date, show24h: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = show24h ? "HH:mm" : "h:mm a"
        return formatter.string(from: date)
    }
}

/**
 Digital clock widget view displaying only the digital time.
 
 Reads settings from shared App Group storage and always hides seconds.
 */
struct DigitalClockWidgetView: View {
    /// The timeline entry containing the date to display.
    let entry: ClockEntry
    
    var body: some View {
        let settings = loadWidgetSettings()
        
        VStack {
            Spacer()
            Text(formatTime(entry.date, show24h: settings.show24h))
                .font(.system(size: 48, weight: .semibold, design: .monospaced))
                .foregroundColor(Color(hex: settings.digitalColor))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Spacer()
        }
        .widgetBackground(Color.clear)
    }
    
    /**
     Formats the time without seconds for widget display.
     
     - Parameters:
        - date: The date to format.
        - show24h: Whether to use 24-hour format.
     - Returns: Formatted time string without seconds.
     */
    private func formatTime(_ date: Date, show24h: Bool) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = show24h ? "HH:mm" : "h:mm a"
        return formatter.string(from: date)
    }
}
