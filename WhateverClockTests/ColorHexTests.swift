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

    @Test("Invalid input falls back to black", arguments: ["", "#", "zzzzzz", "#12345", "#1234567", "#12ZZZZ", "12345G", "#F0G", "#１２３４５６"])
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
        #expect(hex == "#FF0000")
    }

    @Test func convertsDisplayP3ToSRGB() throws {
        let p3 = try #require(CGColorSpace(name: CGColorSpace.displayP3))
        let srgb = try #require(CGColorSpace(name: CGColorSpace.sRGB))
        let p3Color = try #require(CGColor(colorSpace: p3, components: [0.8, 0.3, 0.2, 1]))
        let expected = try #require(p3Color.converted(to: srgb, intent: .relativeColorimetric, options: nil)?.components)
        let expectedHex = String(format: "#%02X%02X%02X", Int((expected[0] * 255).rounded()), Int((expected[1] * 255).rounded()), Int((expected[2] * 255).rounded()))

        // Raw P3 components would be #CC4D33; the stored value must be the sRGB equivalent.
        #expect(expectedHex != "#CC4D33")
        #expect(Color(cgColor: p3Color).hex == expectedHex)
    }
}
