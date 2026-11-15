import Testing
import SwiftUI
@testable import WhateverClock

@Suite("Color <-> hex conversion")
struct ColorHexTests {
    @Test("Round-trips hex strings", arguments: ["#000000", "#FFFFFF", "#FF3B30", "#123456", "#ABCDEF", "#7F7F7F"])
    func roundTrip(hex: String) {
        #expect(Color(hex: hex).hex == hex)
    }

    @Test func acceptsMissingHashLowercaseAndWhitespace() {
        #expect(Color(hex: "ff8800").hex == "#FF8800")
        #expect(Color(hex: "  #00ff00\n").hex == "#00FF00")
    }

    @Test func expandsShortForm() {
        #expect(Color(hex: "#F0A").hex == "#FF00AA")
    }

    @Test("Invalid input falls back to black", arguments: ["", "#", "zzzzzz", "#12345", "#1234567"])
    func invalidInput(hex: String) {
        #expect(Color(hex: hex).hex == "#000000")
    }

    @Test func systemColorsProduceValidHex() {
        for color in [Color.red, .blue, .gray, .white, .black] {
            let hex = color.hex
            #expect(hex.count == 7)
            #expect(hex.hasPrefix("#"))
        }
        #expect(Color.white.hex == "#FFFFFF")
        #expect(Color.black.hex == "#000000")
    }

    @Test func clampsExtendedRangeColors() {
        let extended = Color(UIColor(displayP3Red: 1, green: 0, blue: 0, alpha: 1))
        let hex = extended.hex
        #expect(hex.count == 7)
        #expect(hex.hasPrefix("#FF"))
    }
}
