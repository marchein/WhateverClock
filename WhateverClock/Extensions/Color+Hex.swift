//
//  Color+Hex.swift
//  WhateverClock
//
//  Created by Marc Hein on 26.01.26.
//

import SwiftUI
import UIKit

/**
 Utilities for converting Color <-> Hex String for persistent storage.
 */
extension Color {
    /// Converts the color to an sRGB `#RRGGBB` string. Components outside sRGB are clamped.
    var hex: String {
        let resolved = UIColor(self).resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        // Convert explicitly (e.g. from Display P3), since `init(hex:)` interprets the stored value as sRGB.
        guard let extendedSRGB = CGColorSpace(name: CGColorSpace.extendedSRGB),
              let converted = resolved.cgColor.converted(to: extendedSRGB, intent: .relativeColorimetric, options: nil)
        else { return "#000000" }
        let uiColor = UIColor(cgColor: converted)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        func component(_ value: CGFloat) -> Int { max(0, min(255, Int((value * 255).rounded()))) }
        return String(format: "#%02X%02X%02X", component(r), component(g), component(b))
    }

    /// Initializes a Color from a hex string (`#RRGGBB`, `RRGGBB` or `#RGB`). Invalid input yields black.
    init(hex: String) {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if sanitized.hasPrefix("#") { sanitized.removeFirst() }
        if sanitized.count == 3 {
            sanitized = sanitized.map { "\($0)\($0)" }.joined()
        }
        var rgb: UInt64 = 0
        if sanitized.count != 6
            || !sanitized.allSatisfy({ "0123456789abcdefABCDEF".contains($0) })
            || !Scanner(string: sanitized).scanHexInt64(&rgb) {
            rgb = 0
        }
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
