//
//  ClockModel.swift
//  WhateverClock
//
//  Created by Marc Hein on 26.01.26.
//

import SwiftUI
import Combine

/**
 `ClockModel` is an observable model object that drives the live clock animation in WhateverClock.
 
 - Uses a high-frequency timer to publish updates for the current date, ensuring smooth clock hand animations.
 - Automatically starts the timer upon initialization and stops it on deinitialization.
 */
final class ClockModel: ObservableObject {
    /// The currently published date, updated at high frequency (60 Hz).
    @Published var date: Date = Date()
    
    /// Internal timer for updating the date.
    private var timer: Timer?

    /**
     Initializes the clock model and starts the timer.
     */
    init() {
        startTimer()
    }

    /**
     Cleans up the timer when the object is deallocated.
     */
    deinit {
        timer?.invalidate()
    }

    /**
     Starts the timer to regularly fetch and publish the current time.
     
     - The timer fires every 1/60th of a second (60 Hz).
     - Uses a weak reference to self to prevent retain cycles.
     - Timer is scheduled in the common run loop mode.
     */
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60, repeats: true) { [weak self] _ in
            self?.date = Date()
        }
        if let timer = timer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
}
