//
//  View+WidgetBackground.swift
//  WhateverClockWidget
//
//  Created by GitHub Copilot on 28.01.26.
//

import SwiftUI
import WidgetKit

/**
 Extension providing iOS 16.6+ compatible widget background modifier.
 
 Provides a unified API for widget backgrounds that works across iOS 16.6+ and iOS 17+.
 On iOS 17+, uses the native `containerBackground(for:)` modifier.
 On iOS 16.6, applies the background using the older `background()` modifier.
 */
extension View {
    /**
     Applies a background to a widget view in a cross-version compatible way.
     
     - Parameter background: The view to use as the background.
     - Returns: A view with the background applied.
     */
    @ViewBuilder
    func widgetBackground<Background: View>(_ background: Background) -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(for: .widget) {
                background
            }
        } else {
            self.background(background)
        }
    }
}
