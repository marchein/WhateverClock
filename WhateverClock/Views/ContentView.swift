import SwiftUI

/// The main content view displaying an analog and digital clock with access to settings.
struct ContentView: View {
    /// Stores the user settings for clock appearance and behavior.
    @ObservedObject var settings: SettingsModel
    /// Determines whether the settings screen is presented.
    @State private var showSettings = false
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        NavigationStack {
            // With a second hand we redraw every frame for a smooth sweep; otherwise once per second
            // is plenty. TimelineView also pauses automatically while the app is in the background.
            TimelineView(.animation(minimumInterval: settings.showSeconds ? nil : 1)) { context in
                let layout = verticalSizeClass == .compact
                    ? AnyLayout(HStackLayout(spacing: 32))
                    : AnyLayout(VStackLayout(spacing: 48))
                layout {
                    ClassicAnalogClockView(
                        date: context.date,
                        showSeconds: settings.showSeconds,
                        numberColor: settings.color(from: settings.numberColorHex),
                        indexColor: settings.color(from: settings.coupleIndexNumberColor ? settings.numberColorHex : settings.indexColorHex),
                        faceColor: settings.color(from: settings.clockFaceColorHex),
                        handsColor: settings.color(from: settings.handsColorHex),
                        secondsColor: settings.color(from: settings.secondsColorHex)
                    )

                    DigitalClockView(
                        date: context.date,
                        showSeconds: settings.showSeconds,
                        showMilliseconds: settings.showMilliseconds,
                        show24h: settings.show24h
                    )
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical)
            }
            .navigationTitle(Text(verbatim: "WhateverClock"))
            .navigationBarTitleDisplayMode(verticalSizeClass == .compact ? .inline : .large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .buttonStyleIfAvailableGlassProminent()
                    .accessibilityLabel("Open settings")
                    .accessibilityIdentifier("openSettingsButton")
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsScreen(settings: settings)
        }
    }
}

#Preview {
    ContentView(settings: SettingsModel(store: UserDefaults(suiteName: "preview")!, reloadsWidgets: false))
}
