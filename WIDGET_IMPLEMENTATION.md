# WhateverClock Widget Implementation Summary

## Overview
This document describes the implementation of the WidgetKit extension for WhateverClock, providing home screen widgets that display analog and digital clocks synchronized with the main app's settings.

## Architecture

### App Group Sharing
- **App Group ID**: `group.de.marchein.WhateverClock`
- Settings are stored in shared UserDefaults accessible by both the main app and widget extension
- Entitlements files configured for both targets

### Widget Types
1. **AnalogClockWidget**: Displays only an analog clock
   - Supported families: Small, Medium, Large
   
2. **AnalogDigitalClockWidget**: Displays analog clock (left) and digital time (right)
   - Supported families: Medium only
   
3. **DigitalClockWidget**: Displays only digital time
   - Supported families: Medium only

### Key Features
- **Minute-boundary updates**: Widgets update exactly at the start of each minute
- **No seconds display**: Seconds are always hidden in widgets (no second hand, digital shows HH:mm)
- **Settings sync**: Widgets automatically reflect color changes made in the main app
- **iOS 16.6+ compatibility**: Uses conditional compilation for widget background API

## File Structure

### New Files
- `WhateverClockWidget/WhateverClockWidget.swift` - Main widget bundle and timeline provider
- `WhateverClockWidget/WidgetViews.swift` - Widget view implementations
- `WhateverClockWidget/View+WidgetBackground.swift` - iOS version compatibility helper
- `WhateverClockWidget/Info.plist` - Widget extension metadata
- `WhateverClockWidget/WhateverClockWidget.entitlements` - App Group entitlements
- `WhateverClock/Model/SharedConstants.swift` - Shared constants for App Group
- `WhateverClock/WhateverClock.entitlements` - Main app entitlements

### Modified Files
- `WhateverClock/Model/SettingsModel.swift` - Updated to use App Group storage, added digitalColor
- `WhateverClock/Clock/ClassicAnalogClockView.swift` - Fixed ForEach typo
- `WhateverClock/Clock/DigitalClockView.swift` - Added textColor parameter
- `WhateverClock/Views/ContentView.swift` - Updated to pass textColor to DigitalClockView

### Shared Files (via symlinks)
The following files are shared between the main app and widget extension:
- `ClassicAnalogClockView.swift`
- `DigitalClockView.swift`
- `RoundedHand.swift`
- `SecondHand.swift`
- `Color+Hex.swift`
- `SharedConstants.swift`

## Timeline Provider Implementation

The `ClockTimelineProvider` generates timeline entries:
1. Calculates the next minute boundary from the current time
2. Generates 60 entries (one per minute) for the next hour
3. Sets refresh policy to update after the last entry
4. Ensures widgets always display the correct time aligned to minute boundaries

## Settings Management

### Shared Settings
All settings are stored in the App Group UserDefaults:
- Clock face color
- Number color
- Index color
- Hands color
- Seconds color
- Digital color (new)
- Couple index/number color flag
- Clock size
- Show seconds
- Show milliseconds
- 24-hour format

### Default Values
The widget helper function `loadWidgetSettings()` properly handles default values:
- Colors default to appropriate values (white face, black numbers, etc.)
- Boolean settings check for key existence to provide correct defaults
- `coupleIndexNumberColor` defaults to `true`
- `show24h` defaults to `true`

## iOS Compatibility

The `View+WidgetBackground` extension provides cross-version compatibility:
- iOS 17+: Uses `containerBackground(for: .widget)`
- iOS 16.6: Falls back to `background()` modifier

## Build Configuration

### Widget Extension Target
- Bundle ID: `de.marc-hein.WhateverClock.WhateverClockWidget`
- Deployment target: iOS 16.6+
- Product type: App Extension
- Uses `PBXFileSystemSynchronizedRootGroup` for automatic file inclusion

### Entitlements
Both targets include the App Group capability:
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.de.marchein.WhateverClock</string>
</array>
```

## Usage

1. Users can add widgets from the widget gallery
2. Widgets automatically sync with app settings
3. Changes made in the app's settings screen immediately affect widgets
4. Widgets update at minute boundaries for accurate timekeeping

## Testing Checklist

- [ ] Widgets display correctly in all supported sizes
- [ ] Settings sync between app and widgets
- [ ] Widgets update at minute boundaries
- [ ] Digital color setting works in widgets
- [ ] No seconds are displayed in widgets
- [ ] Widgets work on iOS 16.6 and iOS 17+
- [ ] App builds successfully with widget extension
