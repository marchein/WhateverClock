//
//  WhateverClockApp.swift
//  WhateverClock
//
//  Created by Marc Hein on 26.01.26.
//

import SwiftUI

@main
struct WhateverClockApp: App {
    @StateObject private var settings: SettingsModel

    init() {
        _settings = StateObject(wrappedValue: Self.makeSettings(arguments: ProcessInfo.processInfo.arguments))
    }

    var body: some Scene {
        WindowGroup {
            ContentView(settings: settings)
        }
    }

    /// UI tests pass `--uitesting` to use an isolated store (and `--reset-settings` to start clean),
    /// so tests never touch the real App Group settings or reload widgets.
    static func makeSettings(arguments: [String]) -> SettingsModel {
        guard arguments.contains("--uitesting") else { return SettingsModel() }
        let suiteName = "de.marc-hein.WhateverClock.uitests"
        let store = UserDefaults(suiteName: suiteName) ?? .standard
        if arguments.contains("--reset-settings") {
            store.removePersistentDomain(forName: suiteName)
        }
        return SettingsModel(store: store, reloadsWidgets: false)
    }
}
