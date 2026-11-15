//
//  ClockHandAngles.swift
//  WhateverClock
//
//  Shared between the app and the widget extension.
//

import Foundation

/// Rotation angles (in degrees, clockwise from 12 o'clock) of the clock hands for a given date.
struct ClockHandAngles: Equatable {
    let hour: Double
    let minute: Double
    let second: Double

    init(date: Date, calendar: Calendar = .current) {
        let comps = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
        let seconds = Double(comps.second ?? 0) + Double(comps.nanosecond ?? 0) / 1_000_000_000
        let minutes = Double(comps.minute ?? 0) + seconds / 60
        let hours = Double((comps.hour ?? 0) % 12) + minutes / 60
        hour = hours * 30
        minute = minutes * 6
        second = seconds * 6
    }
}
