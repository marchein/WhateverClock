import SwiftUI

/**
 `SettingsScreen` is a SwiftUI view that presents user configuration options for WhateverClock.
 
 Displays settings in a structured form, including appearance and behavior customization.
 Automatically persists changes using `SettingsModel`.
 
 - Note: Uses localization in German for labels.
 */
struct SettingsScreen: View {
    /// The observable settings model backing this screen.
    @ObservedObject var settings: SettingsModel
    /// Dismiss environment for closing the settings screen.
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // Section: Display Options
                Section {
                    Toggle("24 hour display", isOn: $settings.show24h)
                    Toggle("Show seconds", isOn: $settings.showSeconds)
                    Toggle("Show milliseconds", isOn: $settings.showMilliseconds)
                        .disabled(!settings.showSeconds) // Only enable if seconds are shown
                } header: {
                    Text("Clock")
                }
                
                // Section: Appearance Options
                Section {
                    ColorPicker("Dial color", selection: Binding(
                        get: { settings.color(from: settings.clockFaceColorHex) },
                        set: { settings.setClockFaceColor($0) }
                    ))
                    ColorPicker("Number color", selection: Binding(
                        get: { settings.color(from: settings.numberColorHex) },
                        set: { settings.setNumberColor($0) }
                    ))
                    Toggle("Couple index and number colors", isOn: $settings.coupleIndexNumberColor)
                    if !settings.coupleIndexNumberColor {
                        ColorPicker("Index color", selection: Binding(
                            get: { settings.color(from: settings.indexColorHex) },
                            set: { settings.setIndexColor($0) }
                        ))
                    }
                    ColorPicker("Hands color", selection: Binding(
                        get: { settings.color(from: settings.handsColorHex) },
                        set: { settings.handsColorHex = $0.hex }
                    ))
                    ColorPicker("Secondhand color", selection: Binding(
                        get: { settings.color(from: settings.secondsColorHex) },
                        set: { settings.setSecondsColor($0) }
                    ))
                } header: {
                    Text("Design")
                }
                
                // Section: App Version and Build like "1.0.0 (1)"
                Section {
                    HStack {
                        Text("App Version")
                        Spacer()
                        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                            Text("\(version) (Build \(build))")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Not available")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("About")
                }
                
                // Section: Reset Options
                Section {
                    Button("Reset design to default") {
                        settings.resetDesign()
                    }
                    Button {
                        settings.resetAll()
                    } label: {
                        Text("Reset all settings to default")
                            .foregroundStyle(.red)
                    }

                } header: {
                    Text("Reset")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                    .buttonStyleIfAvailableGlassProminent()
                }
            }
        }
    }
}

/**
 Preview provider for SettingsScreen with default SettingsModel.
 */
struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen(settings: SettingsModel())
    }
}
