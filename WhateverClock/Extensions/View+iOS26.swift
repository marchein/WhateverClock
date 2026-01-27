//
//  View+iOS26.swift
//  WhateverClock
//
//  Created by Marc Hein on 27.01.26.
//

import SwiftUI

extension View {
    /// Applies `.glassProminent` button style if available on iOS 26.0 and above.
    @ViewBuilder
    func buttonStyleIfAvailableGlassProminent() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self
        }
    }
}
