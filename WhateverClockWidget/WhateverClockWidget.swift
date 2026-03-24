//
//  WhateverClockWidget.swift
//  WhateverClockWidget
//
//  Created by Marc Hein on 26.01.26.
//

import WidgetKit
import SwiftUI

// MARK: - App Group identifier

private let appGroupIdentifier = "group.de.marc-hein.WhateverClock"

// MARK: - Clock Settings (read from shared UserDefaults)

/**
 Holds a snapshot of the user's clock appearance settings read from the App Group UserDefaults.
 Falls back to defaults when the shared store is unavailable or a key is missing.
 */
struct ClockWidgetSettings {
    let clockFaceColorHex: String
    let numberColorHex: String
    let indexColorHex: String
    let handsColorHex: String
    let coupleIndexNumberColor: Bool
    let showSeconds: Bool

    /// Default settings matching the app's initial defaults.
    static let defaults = ClockWidgetSettings(
        clockFaceColorHex: "#FFFFFF",
        numberColorHex: "#000000",
        indexColorHex: "#000000",
        handsColorHex: "#000000",
        coupleIndexNumberColor: true,
        showSeconds: true
    )

    /// Reads settings from the shared App Group UserDefaults.
    static func fromUserDefaults() -> ClockWidgetSettings {
        let store = UserDefaults(suiteName: appGroupIdentifier) ?? .standard
        return ClockWidgetSettings(
            clockFaceColorHex: store.string(forKey: "clockFaceColor") ?? "#FFFFFF",
            numberColorHex: store.string(forKey: "numberColor") ?? "#000000",
            indexColorHex: store.string(forKey: "indexColor") ?? "#000000",
            handsColorHex: store.string(forKey: "handsColor") ?? "#000000",
            coupleIndexNumberColor: store.object(forKey: "coupleIndexNumberColor") as? Bool ?? true,
            showSeconds: store.object(forKey: "showSeconds") as? Bool ?? true
        )
    }

    var faceColor: Color { Color(hex: clockFaceColorHex) }
    var numberColor: Color { Color(hex: numberColorHex) }
    /// Respects the "couple index and number colors" toggle.
    var indexColor: Color { Color(hex: coupleIndexNumberColor ? numberColorHex : indexColorHex) }
    var handsColor: Color { Color(hex: handsColorHex) }
}

// MARK: - Timeline Entry

/// A single point in the widget's timeline carrying the time and current settings snapshot.
struct ClockEntry: TimelineEntry {
    let date: Date
    let settings: ClockWidgetSettings
}

// MARK: - Timeline Provider

/// Provides timeline entries for WhateverClockWidget, refreshing every hour.
struct WhateverClockProvider: TimelineProvider {
    func placeholder(in context: Context) -> ClockEntry {
        ClockEntry(date: Date(), settings: .defaults)
    }

    func getSnapshot(in context: Context, completion: @escaping (ClockEntry) -> Void) {
        completion(ClockEntry(date: Date(), settings: .fromUserDefaults()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ClockEntry>) -> Void) {
        let settings = ClockWidgetSettings.fromUserDefaults()
        let now = Date()
        // One entry per minute for the next 2 hours so the hands stay accurate.
        let entries: [ClockEntry] = (0..<120).compactMap { offset in
            guard let entryDate = Calendar.current.date(
                byAdding: .minute, value: offset, to: now
            ) else { return nil }
            return ClockEntry(date: entryDate, settings: settings)
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

// MARK: - Clock Hand Views

/// A thick clock hand (hour or minute) with rounded caps and a subtle shadow.
private struct WidgetRoundedHand: View {
    let length: CGFloat
    let width: CGFloat
    let color: Color
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

/// The thin second hand.
private struct WidgetSecondHand: View {
    let length: CGFloat
    let color: Color
    let rotation: Angle

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 3, height: length)
            .offset(y: -length / 2)
            .rotationEffect(rotation)
    }
}

// MARK: - Analog Clock View for Widget

/**
 A self-contained analog clock view for the widget.
 All appearance constants are derived from the clock geometry so the clock
 fills any widget size correctly.
 */
private struct WidgetAnalogClockView: View {
    let date: Date
    let showSeconds: Bool
    let numberColor: Color
    let indexColor: Color
    let faceColor: Color
    let handsColor: Color

    private func borderWidth(for size: CGFloat) -> CGFloat { size * 0.035 }
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
            let clockSize = min(availableWidth, availableHeight) + 10
            ZStack {
                // Face & border
                Circle()
                    .fill(faceColor)
                    .overlay(
                        Circle()
                            .stroke(Color(.sRGB, white: 0.16, opacity: 1.0),
                                    lineWidth: borderWidth(for: clockSize))
                    )

                // Indices
                ForEach(0..<60) { tick in
                    Capsule()
                        .fill(tick % 5 == 0 ? indexColor : indexColor.opacity(0.7))
                        .frame(
                            width: tick % 5 == 0 ? clockSize * 0.0125 : clockSize * 0.0064,
                            height: tick % 5 == 0 ? indexLengthHour(for: clockSize) : indexLengthMinute(for: clockSize)
                        )
                        .offset(y: -clockSize / 2
                            + borderWidth(for: clockSize)
                            + (tick % 5 == 0 ? indexLengthHour(for: clockSize) / 2 : indexLengthMinute(for: clockSize) / 2)
                            + clockSize * 0.018
                        )
                        .opacity(tick % 5 == 0 ? 1 : 0.7)
                        .rotationEffect(.degrees(Double(tick) * 6))
                }

                // Numbers 1–12
                ForEach(1...12, id: \.self) { hour in
                    let angle = Double(hour) * .pi / 6
                    let r: CGFloat = clockSize / 2
                        - borderWidth(for: clockSize)
                        - indexLengthHour(for: clockSize)
                        - clockSize * 0.08
                    Text("\(hour)")
                        .font(.system(size: clockSize * 0.1, weight: .bold, design: .rounded))
                        .foregroundColor(numberColor)
                        .position(
                            x: clockSize / 2 + CGFloat(sin(angle)) * r,
                            y: clockSize / 2 - CGFloat(cos(angle)) * r
                        )
                }

                // Hand calculations
                let calendar = Calendar.current
                let comps = calendar.dateComponents([.hour, .minute, .second], from: date)
                let hour = CGFloat(comps.hour ?? 0) + CGFloat(comps.minute ?? 0) / 60
                let minute = CGFloat(comps.minute ?? 0) + CGFloat(comps.second ?? 0) / 60

                // Hands
                WidgetRoundedHand(
                    length: hourHandLength(for: clockSize),
                    width: hourHandWidth(for: clockSize),
                    color: handsColor,
                    rotation: .degrees(Double(hour) * 30)
                )
                WidgetRoundedHand(
                    length: minuteHandLength(for: clockSize),
                    width: minuteHandWidth(for: clockSize),
                    color: handsColor,
                    rotation: .degrees(Double(minute) * 6)
                )


                Circle()
                    .stroke(Color(.sRGB, white: 0.18, opacity: 1.0),
                            lineWidth: clockSize * 0.0062)
                    .background(Circle().fill(faceColor))
                    .frame(width: handRadius(for: clockSize),
                           height: handRadius(for: clockSize))
            }
            .frame(width: clockSize, height: clockSize)
            .position(x: availableWidth / 2, y: availableHeight / 2)
        }
    }
}

// MARK: - Widget Entry View

struct WhateverClockWidgetEntryView: View {
    let entry: ClockEntry
    @Environment(\.widgetFamily) private var widgetFamily

    var body: some View {
        Group {
            switch widgetFamily {
            case .systemLarge:
                largeBody
            case .systemMedium:
                mediumBody
            default:
                smallBody
            }
        }
        .widgetBackground(entry.settings.faceColor)
    }

    /// Small widget: analog clock filling the available space.
    @ViewBuilder
    private var smallBody: some View {
        WidgetAnalogClockView(
            date: entry.date,
            showSeconds: entry.settings.showSeconds,
            numberColor: entry.settings.numberColor,
            indexColor: entry.settings.indexColor,
            faceColor: entry.settings.faceColor,
            handsColor: entry.settings.handsColor
        )
    }

    /// Medium widget: analog clock on the left, digital time on the right.
    @ViewBuilder
    private var mediumBody: some View {
        HStack(spacing: 0) {
            WidgetAnalogClockView(
                date: entry.date,
                showSeconds: entry.settings.showSeconds,
                numberColor: entry.settings.numberColor,
                indexColor: entry.settings.indexColor,
                faceColor: entry.settings.faceColor,
                handsColor: entry.settings.handsColor
            )
            .padding(8)

            VStack {
                Text(entry.date, style: .time)
                    .font(.system(.title, design: .rounded, weight: .semibold).monospacedDigit())
                    .foregroundColor(entry.settings.numberColor)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text(entry.date, style: .date)
                    .font(.system(.caption, design: .rounded, weight: .regular))
                    .foregroundColor(entry.settings.numberColor.opacity(0.7))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            .padding(.trailing, 12)
            .frame(maxWidth: .infinity)
        }
    }
    
    /// Large widget: analog clock filling the available space.
    @ViewBuilder
    private var largeBody: some View {
        WidgetAnalogClockView(
            date: entry.date,
            showSeconds: entry.settings.showSeconds,
            numberColor: entry.settings.numberColor,
            indexColor: entry.settings.indexColor,
            faceColor: entry.settings.faceColor,
            handsColor: entry.settings.handsColor
        )
    }
}

// MARK: - Background helper (iOS 16 / 17 compatibility)

private extension View {
    @ViewBuilder
    func widgetBackground(_ color: Color) -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(color, for: .widget)
        } else {
            background(color)
        }
    }
}

// MARK: - Widget Definition

struct WhateverClockWidget: Widget {
    let kind: String = "WhateverClockWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WhateverClockProvider()) { entry in
            WhateverClockWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("WhateverClock")
        .description("Shows the WhateverClock analog clock with your custom colors.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemExtraLarge])
    }
}

// MARK: - Widget Bundle

@main
struct WhateverClockWidgetBundle: WidgetBundle {
    var body: some Widget {
        WhateverClockWidget()
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    WhateverClockWidget()
} timeline: {
    ClockEntry(date: .now, settings: .defaults)
}

#Preview(as: .systemMedium) {
    WhateverClockWidget()
} timeline: {
    ClockEntry(date: .now, settings: .defaults)
}

#Preview(as: .systemLarge) {
    WhateverClockWidget()
} timeline: {
    ClockEntry(date: .now, settings: .defaults)
}
