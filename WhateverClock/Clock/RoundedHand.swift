//
//  RoundedHand.swift
//  WhateverClock
//
//  Created by Marc Hein on 26.01.26.
//

import SwiftUI

/**
 A SwiftUI View that draws a thick clock hand (hour or minute) with rounded caps and a shadow.
 
 This view is typically used to visually represent the hour or minute hands in the WhateverClock app.
 
 - Parameters:
    - length: The length of the clock hand.
    - width: The width (thickness) of the clock hand.
    - color: The color of the clock hand.
    - rotation: The angle in degrees of rotation to position the hand appropriately.
 
 - Important:
    The hand's center is offset so the base aligns with the clock face center.
    The provided color is also used for an optional subtle shadow below the hand.
 */
struct RoundedHand: View {
    /// The length of the hand from base to tip.
    let length: CGFloat
    /// The width (thickness) of the hand.
    let width: CGFloat
    /// The color of the clock hand.
    let color: Color
    /// The rotation angle for positioning the hand.
    let rotation: Angle

    var body: some View {
        Capsule()
            .fill(color)
            .frame(width: width, height: length)
            .offset(y: -length / 2)
            .rotationEffect(rotation)
            .shadow(color: color.opacity(0.14), radius: 1, x: 0, y: 2)
    }
}

/**
 Preview provider for RoundedHand to visualize appearance at design time.
 */
struct RoundedHand_Previews: PreviewProvider {
    static var previews: some View {
        RoundedHand(length: 100, width: 10, color: .blue, rotation: .degrees(45))
            .frame(width: 200, height: 200)
            .background(Color.gray.opacity(0.2))
    }
}
