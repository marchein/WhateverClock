//
//  Color+Hex.swift
//  WhateverClockWidget
//
//  Created by Marc Hein on 26.01.26.
//

import SwiftUI
import UIKit

/**
 Utilities for converting Color <-> Hex String for persistent storage.
 Handles both iOS (UIColor) and macOS (NSColor).
 */
extension Color {
    /// Converts Color to HEX string. Defaults to white if conversion fails.
    var hex: String {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)

        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
    
    /// Initializes a Color from a hex string (e.g. "#RRGGBB").
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
