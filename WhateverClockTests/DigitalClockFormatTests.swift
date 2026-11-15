import Testing
import Foundation
@testable import WhateverClock

@Suite("Digital clock formatting")
struct DigitalClockFormatTests {
    private let utc = TimeZone(identifier: "UTC")!
    private let enUS = Locale(identifier: "en_US")
    /// 2026-01-26 14:05:09.456 UTC
    private let date = Date(timeIntervalSince1970: 1_769_436_309.456)

    private func format(seconds: Bool, ms: Bool, h24: Bool) -> String {
        DigitalClockView.string(from: date, showSeconds: seconds, showMilliseconds: ms, show24h: h24, locale: enUS, timeZone: utc)
    }

    @Test func twentyFourHour() {
        #expect(format(seconds: false, ms: false, h24: true) == "14:05")
        #expect(format(seconds: true, ms: false, h24: true) == "14:05:09")
        #expect(format(seconds: true, ms: true, h24: true) == "14:05:09.45")
    }

    @Test func twelveHour() {
        #expect(format(seconds: false, ms: false, h24: false) == "2:05 PM")
        #expect(format(seconds: true, ms: false, h24: false) == "2:05:09 PM")
        #expect(format(seconds: true, ms: true, h24: false) == "2:05:09.45 PM")
    }

    @Test("Milliseconds are ignored without seconds", arguments: [true, false])
    func millisecondsRequireSeconds(h24: Bool) {
        #expect(format(seconds: false, ms: true, h24: h24) == format(seconds: false, ms: false, h24: h24))
    }

    @Test func respectsTimeZone() {
        let berlin = TimeZone(identifier: "Europe/Berlin")!
        let text = DigitalClockView.string(from: date, showSeconds: false, showMilliseconds: false, show24h: true, locale: enUS, timeZone: berlin)
        #expect(text == "15:05")
    }

    @Test func dateFormatPatterns() {
        #expect(DigitalClockView.dateFormat(showSeconds: true, showMilliseconds: true, show24h: true) == "HH:mm:ss.SS")
        #expect(DigitalClockView.dateFormat(showSeconds: false, showMilliseconds: false, show24h: false) == "h:mm a")
    }
}
