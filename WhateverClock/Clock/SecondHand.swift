//
//  SecondHand.swift
//  WhateverClock
//
//  Created by Marc Hein on 26.01.26.
//

import SwiftUI

/**
 A SwiftUI View that draws the second hand of a clock.
 
 This view visually represents the sweeping second hand in the WhateverClock app.
 
 - Parameters:
    - length: The length of the second hand.
    - color: The color of the second hand.
    - rotation: The angle in degrees for the second hand's current position.
 
 - Important:
    The hand's center is offset so the base aligns with the clock face center.
    The hand shaft is intentionally narrow for a classic second hand appearance.
 */
struct SecondHand: View {
    /// The length of the second hand.
    let length: CGFloat
    /// The color of the second hand.
    let color: Color
    /// The rotation angle for positioning the hand.
    let rotation: Angle

    var body: some View {
        ZStack {
            // Hand shaft
            Rectangle()
                .fill(color)
                .frame(width: 3, height: length)
                .offset(y: -length / 2)
                .rotationEffect(rotation)
        }
    }
}
