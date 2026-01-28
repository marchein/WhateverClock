//
//  WhateverClockWidget.swift
//  WhateverClockWidget
//
//  Created by GitHub Copilot on 28.01.26.
//

import WidgetKit
import SwiftUI

/**
 Main WidgetKit bundle for WhateverClock widgets.
 
 Provides three widget types:
 - Analog clock widget
 - Combined analog and digital clock widget
 - Digital clock widget
 */
@main
struct WhateverClockWidgetBundle: WidgetBundle {
    var body: some Widget {
        AnalogClockWidget()
        AnalogDigitalClockWidget()
        DigitalClockWidget()
    }
}

/**
 Timeline entry containing the date to display in widget views.
 */
struct ClockEntry: TimelineEntry {
    /// The date for this timeline entry.
    let date: Date
}

/**
 Timeline provider for clock widgets.
 
 Generates timeline entries aligned to minute boundaries to ensure widgets update
 precisely at the start of each minute, without displaying seconds.
 */
struct ClockTimelineProvider: TimelineProvider {
    /**
     Provides a placeholder entry for widget preview.
     
     - Parameter context: The context in which the placeholder is displayed.
     - Returns: A clock entry with the current date.
     */
    func placeholder(in context: Context) -> ClockEntry {
        ClockEntry(date: Date())
    }

    /**
     Provides a snapshot entry for widget gallery and quick previews.
     
     - Parameters:
        - context: The context in which the snapshot is displayed.
        - completion: Completion handler called with the snapshot entry.
     */
    func getSnapshot(in context: Context, completion: @escaping (ClockEntry) -> ()) {
        let entry = ClockEntry(date: Date())
        completion(entry)
    }

    /**
     Generates a timeline of entries for the widget.
     
     Creates entries aligned to minute boundaries to ensure the widget updates
     precisely at the start of each minute. Generates entries for the next hour.
     
     - Parameters:
        - context: The context in which the timeline is displayed.
        - completion: Completion handler called with the generated timeline.
     */
    func getTimeline(in context: Context, completion: @escaping (Timeline<ClockEntry>) -> ()) {
        let now = Date()
        let calendar = Calendar.current
        
        // Get the start of the next minute
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        components.minute = (components.minute ?? 0) + 1
        
        guard let startOfNextMinute = calendar.date(from: components) else {
            // Fallback: update in 1 minute
            let entry = ClockEntry(date: now)
            let nextUpdate = calendar.date(byAdding: .minute, value: 1, to: now) ?? now
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
            return
        }
        
        // Generate entries for the next 60 minutes, one per minute
        var entries: [ClockEntry] = []
        for minuteOffset in 0..<60 {
            if let entryDate = calendar.date(byAdding: .minute, value: minuteOffset, to: startOfNextMinute) {
                entries.append(ClockEntry(date: entryDate))
            }
        }
        
        // Set the next update to be at the minute after our last entry
        let nextUpdate = calendar.date(byAdding: .minute, value: 60, to: startOfNextMinute) ?? startOfNextMinute
        let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
        completion(timeline)
    }
}

/**
 Analog clock widget showing only the analog clock face.
 
 Supports small, medium, and large widget sizes.
 */
struct AnalogClockWidget: Widget {
    let kind: String = "AnalogClockWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ClockTimelineProvider()) { entry in
            AnalogClockWidgetView(entry: entry)
        }
        .configurationDisplayName("Analog Clock")
        .description("Display an analog clock.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

/**
 Combined analog and digital clock widget.
 
 Shows analog clock on the left and digital time on the right.
 Only supports medium widget size.
 */
struct AnalogDigitalClockWidget: Widget {
    let kind: String = "AnalogDigitalClockWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ClockTimelineProvider()) { entry in
            AnalogDigitalClockWidgetView(entry: entry)
        }
        .configurationDisplayName("Analog + Digital Clock")
        .description("Display both analog and digital clocks.")
        .supportedFamilies([.systemMedium])
    }
}

/**
 Digital clock widget showing only the digital time.
 
 Only supports medium widget size.
 */
struct DigitalClockWidget: Widget {
    let kind: String = "DigitalClockWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ClockTimelineProvider()) { entry in
            DigitalClockWidgetView(entry: entry)
        }
        .configurationDisplayName("Digital Clock")
        .description("Display a digital clock.")
        .supportedFamilies([.systemMedium])
    }
}
