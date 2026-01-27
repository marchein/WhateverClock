import SwiftUI

/// The main content view displaying an analog and digital clock with access to settings.
/// - Requires: Content must be displayed within a navigation container for the toolbar to appear.
struct ContentView: View {
    /// Holds the current time for the clock views.
    @StateObject private var clockModel = ClockModel()
    /// Stores the user settings for clock appearance and behavior.
    @StateObject private var settings = SettingsModel()
    /// Determines whether the settings screen is presented.
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 64) {
                ClassicAnalogClockView(
                    date: clockModel.date,
                    showSeconds: settings.showSeconds,
                    numberColor: settings.color(from: settings.numberColorHex),
                    indexColor: settings.color(from: settings.coupleIndexNumberColor ? settings.numberColorHex : settings.indexColorHex),
                    faceColor: settings.color(from: settings.clockFaceColorHex),
                    handsColor: settings.color(from: settings.handsColorHex),
                    secondsColor: settings.color(from: settings.secondsColorHex)
                )
                
                
                DigitalClockView(
                    date: clockModel.date,
                    showSeconds: settings.showSeconds,
                    showMilliseconds: settings.showMilliseconds,
                    show24h: settings.show24h
                )
                
            }
            
            .navigationTitle("WhateverClock")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .buttonStyleIfAvailableGlassProminent()
                    .accessibilityLabel("Open settings")
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsScreen(settings: settings)
        }
    }
}

/// Previews the ContentView within a navigation context.
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ContentView()
        }
    }
}
