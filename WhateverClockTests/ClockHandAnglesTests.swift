import Testing
import Foundation
@testable import WhateverClock

@Suite("Clock hand angles")
struct ClockHandAnglesTests {
    private var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    private func date(_ h: Int, _ m: Int, _ s: Int, ns: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 1, day: 26, hour: h, minute: m, second: s, nanosecond: ns))!
    }

    @Test func midnightIsAllZero() {
        let angles = ClockHandAngles(date: date(0, 0, 0), calendar: calendar)
        #expect(angles == ClockHandAngles(date: date(12, 0, 0), calendar: calendar))
        #expect(angles.hour == 0 && angles.minute == 0 && angles.second == 0)
    }

    @Test func threeOClock() {
        let angles = ClockHandAngles(date: date(15, 0, 0), calendar: calendar)
        #expect(angles.hour == 90)
        #expect(angles.minute == 0)
    }

    @Test func halfPastNineMovesHourHandHalfway() {
        let angles = ClockHandAngles(date: date(9, 30, 0), calendar: calendar)
        #expect(angles.hour == 285)
        #expect(angles.minute == 180)
    }

    @Test func secondHandSweepsWithNanoseconds() {
        let angles = ClockHandAngles(date: date(10, 10, 15, ns: 500_000_000), calendar: calendar)
        #expect(abs(angles.second - 93) < 0.01)
        #expect(abs(angles.minute - (10 * 6 + 15.5 / 60 * 6)) < 0.0001)
    }

    @Test func anglesStayWithinFullCircle() {
        let angles = ClockHandAngles(date: date(23, 59, 59, ns: 999_000_000), calendar: calendar)
        #expect(angles.hour < 360 && angles.minute < 360 && angles.second < 360)
    }
}
