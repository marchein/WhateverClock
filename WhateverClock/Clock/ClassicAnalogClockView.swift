//
//  ClassicAnalogClockView.swift
//  WhateverClock
//
//  Created by Marc Hein on 26.01.26.
//

import SwiftUI

/**
 Vector-based analog clock. Colors and size are fully customizable.
 
 - Parameters:
    - date: time to display
    - showSeconds: controls second hand
    - numberColor: color for numbers
    - indexColor: color for indices
    - faceColor: color for clock face
 */
struct ClassicAnalogClockView: View {
    let date: Date
    let showSeconds: Bool
    let numberColor: Color
    let indexColor: Color
    let faceColor: Color
    let handsColor: Color
    let secondsColor: Color
    
    // Appearance constants scaled by size
    private func borderWidth(for size: CGFloat) -> CGFloat { size * 0.05 }
    private func indexLengthHour(for size: CGFloat) -> CGFloat { size * 0.07 }
    private func indexLengthMinute(for size: CGFloat) -> CGFloat { size * 0.04 }
    private func hourHandWidth(for size: CGFloat) -> CGFloat { size * 0.025 }
    private func minuteHandWidth(for size: CGFloat) -> CGFloat { size * 0.013 }
    private func hourHandLength(for size: CGFloat) -> CGFloat { size * 0.27 }
    private func minuteHandLength(for size: CGFloat) -> CGFloat { size * 0.39 }
    private func handRadius(for size: CGFloat) -> CGFloat { size * 0.055 }
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let availableHeight = geometry.size.height
            let idealClockSize = min(availableWidth * 0.9, 600)
            let clockSize = min(idealClockSize, availableHeight)
            ZStack {
                // Face & border
                Circle()
                    .fill(faceColor)
                    .overlay(
                        Circle()
                            .stroke(Color(.sRGB, white: 0.16, opacity: 1.0), lineWidth: borderWidth(for: clockSize))
                    )
                    .shadow(color: Color(UIColor.label), radius: 4)
                
                // Indices
                ForEach(0..<60) { tick in
                    Capsule()
                        .fill(tick % 5 == 0 ? indexColor : indexColor.opacity(0.7))
                        .frame(width: tick % 5 == 0 ? clockSize * 0.0125 : clockSize * 0.0064,
                               height: tick % 5 == 0 ? indexLengthHour(for: clockSize) : indexLengthMinute(for: clockSize))
                        .offset(y: -clockSize/2 + borderWidth(for: clockSize) + (tick % 5 == 0 ? indexLengthHour(for: clockSize)/2 : indexLengthMinute(for: clockSize)/2) + clockSize * 0.018)
                        .opacity(tick % 5 == 0 ? 1 : 0.7)
                        .rotationEffect(.degrees(Double(tick) * 6))
                }
                
                // Numbers
                ForEach(1...12, id: \ .self) { hour in
                    let angle = Double(hour) * .pi / 6
                    // Move numbers further away from indices by increasing the offset
                    let r: CGFloat = clockSize/2 - borderWidth(for: clockSize) - indexLengthHour(for: clockSize) - clockSize * 0.08
                    Text("\(hour)")
                        .font(.system(size: clockSize * 0.1, weight: .bold, design: .rounded))
                        .foregroundColor(numberColor)
                        .position(
                            x: clockSize/2 + CGFloat(sin(angle)) * r,
                            y: clockSize/2 - CGFloat(cos(angle)) * r
                        )
                }
                
                // Hands calculation
                let calendar = Calendar.current
                let comps = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
                let hour = CGFloat(comps.hour ?? 0) + CGFloat(comps.minute ?? 0)/60
                let minute = CGFloat(comps.minute ?? 0) + CGFloat(comps.second ?? 0)/60
                let second = CGFloat(comps.second ?? 0) + CGFloat(comps.nanosecond ?? 0)/1_000_000_000
                
                // Hands drawing
                RoundedHand(
                    length: hourHandLength(for: clockSize),
                    width: hourHandWidth(for: clockSize),
                    color: handsColor,
                    rotation: .degrees(Double(hour) * 30)
                )
                RoundedHand(
                    length: minuteHandLength(for: clockSize),
                    width: minuteHandWidth(for: clockSize),
                    color: handsColor,
                    rotation: .degrees(Double(minute) * 6)
                )
                if showSeconds {
                    SecondHand(
                        length: clockSize/2 - borderWidth(for: clockSize) - clockSize * 0.075,
                        color: secondsColor,
                        rotation: .degrees(Double(second) * 6)
                    )
                    // Center hub
                    Circle()
                        .stroke(secondsColor, lineWidth: clockSize * 0.0062)
                        .background(Circle().fill(secondsColor))
                        .frame(width: handRadius(for: clockSize), height: handRadius(for: clockSize))
                } else {
                    Circle()
                        .stroke(Color(.sRGB, white: 0.18, opacity: 1.0), lineWidth: clockSize * 0.0062)
                        .background(Circle().fill(faceColor))
                        .frame(width: handRadius(for: clockSize), height: handRadius(for: clockSize))
                }
            }
            .frame(width: clockSize, height: clockSize)
            .position(x: availableWidth/2, y: availableHeight/2)
        }
    }
}
