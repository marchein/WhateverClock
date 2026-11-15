import SwiftUI

/**
 `SettingsScreen` presents user configuration options for WhateverClock.
 Changes are persisted immediately through `SettingsModel`.
 */
struct SettingsScreen: View {
    @ObservedObject var settings: SettingsModel
    @Environment(\.dismiss) private var dismiss
    @State private var confirmResetAll = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("24 hour display", isOn: $settings.show24h)
                        .accessibilityIdentifier("toggle24h")
                    Toggle("Show seconds", isOn: $settings.showSeconds)
                        .accessibilityIdentifier("toggleSeconds")
                    Toggle("Show milliseconds", isOn: $settings.showMilliseconds)
                        .disabled(!settings.millisecondsAvailable)
                        .accessibilityIdentifier("toggleMilliseconds")
                } header: {
                    Text("Clock")
                }

                Section {
                    colorPicker("Dial color", hex: settings.clockFaceColorHex, id: "pickerDialColor", set: settings.setClockFaceColor)
                    colorPicker("Number color", hex: settings.numberColorHex, id: "pickerNumberColor", set: settings.setNumberColor)
                    Toggle("Couple index and number colors", isOn: $settings.coupleIndexNumberColor)
                        .accessibilityIdentifier("toggleCoupleColors")
                    if !settings.coupleIndexNumberColor {
                        colorPicker("Index color", hex: settings.indexColorHex, id: "pickerIndexColor", set: settings.setIndexColor)
                    }
                    colorPicker("Hands color", hex: settings.handsColorHex, id: "pickerHandsColor", set: settings.setHandsColor)
                    colorPicker("Secondhand color", hex: settings.secondsColorHex, id: "pickerSecondsColor", set: settings.setSecondsColor)
                } header: {
                    Text("Design")
                }

                Section {
                    LabeledContent("App Version") {
                        Text(Self.versionString)
                            .accessibilityIdentifier("appVersionValue")
                    }
                } header: {
                    Text("About")
                }

                Section {
                    Button("Reset design to default") {
                        settings.resetDesign()
                    }
                    .accessibilityIdentifier("resetDesignButton")
                    Button("Reset all settings to default", role: .destructive) {
                        confirmResetAll = true
                    }
                    .accessibilityIdentifier("resetAllButton")
                } header: {
                    Text("Reset")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .buttonStyleIfAvailableGlassProminent()
                        .accessibilityIdentifier("doneButton")
                }
            }
            .alert("Reset all settings?", isPresented: $confirmResetAll) {
                Button("Reset", role: .destructive) { settings.resetAll() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All colors and display options will be restored to their defaults.")
            }
        }
    }

    private func colorPicker(_ title: LocalizedStringKey, hex: String, id: String, set: @escaping (Color) -> Void) -> some View {
        ColorPicker(title, selection: Binding(get: { Color(hex: hex) }, set: set), supportsOpacity: false)
            .accessibilityIdentifier(id)
    }

    /// "1.0 (Build 2)", or a localized fallback if the bundle info is missing.
    static var versionString: String {
        let info = Bundle.main.infoDictionary
        guard let version = info?["CFBundleShortVersionString"] as? String,
              let build = info?["CFBundleVersion"] as? String else {
            return String(localized: "Not available")
        }
        return "\(version) (Build \(build))"
    }
}

#Preview {
    SettingsScreen(settings: SettingsModel(store: UserDefaults(suiteName: "preview")!, reloadsWidgets: false))
}
