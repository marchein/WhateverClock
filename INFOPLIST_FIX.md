# Fix for Info.plist Build Conflict

## Problem Statement
Xcode build error:
```
Multiple commands produce '/Users/marchein/Library/Developer/Xcode/DerivedData/WhateverClock-hklldazmqivnlodzqjbhbbvjpujb/Build/Products/Debug-iphonesimulator/WhateverClockWidget.appex/Info.plist'
```

## Root Cause

The WhateverClockWidget target was configured with:
1. **PBXFileSystemSynchronizedRootGroup** - A modern Xcode feature that automatically includes all files in a directory for compilation/resources
2. **Build Settings** with:
   - `GENERATE_INFOPLIST_FILE = NO`
   - `INFOPLIST_FILE = WhateverClockWidget/Info.plist`

This created a conflict:
- The synchronized group automatically added Info.plist to the "Copy Bundle Resources" phase
- The build settings also tried to use Info.plist as the target's info plist file
- Result: Two build commands trying to produce the same output file

## Solution

Added a `PBXFileSystemSynchronizedGroupBuildPhaseMembershipExceptionSet` to exclude Info.plist from the Copy Bundle Resources phase, similar to the pattern already used in the main app target.

### Changes Made

**In `WhateverClock.xcodeproj/project.pbxproj`:**

1. Added exception set to exclude Info.plist:
```xml
2B4E09E156104BC697AAC480 /* Exceptions for "WhateverClockWidget" folder in "Copy Bundle Resources" phase from "WhateverClockWidget" target */ = {
    isa = PBXFileSystemSynchronizedGroupBuildPhaseMembershipExceptionSet;
    buildPhase = 7D86EA61C5F344CCAB11835A /* Resources */;
    membershipExceptions = (
        Info.plist,
    );
};
```

2. Referenced exception in WhateverClockWidget synchronized root group:
```xml
6D8FD2A31ECC44A5A7F89F4F /* WhateverClockWidget */ = {
    isa = PBXFileSystemSynchronizedRootGroup;
    exceptions = (
        2B4E09E156104BC697AAC480 /* Exceptions for "WhateverClockWidget" folder in "Copy Bundle Resources" phase from "WhateverClockWidget" target */,
    );
    path = WhateverClockWidget;
    sourceTree = "<group>";
};
```

## How It Works

Now the build process:
1. ✅ Info.plist is **excluded** from Copy Bundle Resources phase
2. ✅ Info.plist is **used** as the target's info plist file (via `INFOPLIST_FILE` setting)
3. ✅ No conflict - only one command processes Info.plist

## Pattern Used

This follows the same pattern already established in the main WhateverClock target:
- Main app excludes `Extensions/Color+Hex.swift` from resources
- Widget now excludes `Info.plist` from resources

Both cases prevent files from being inadvertently copied as resources when they serve other purposes in the build.

## Verification

The project should now build successfully without the "Multiple commands produce" error. The widget will still have its Info.plist properly configured at:
- Build-time location: `WhateverClockWidget/Info.plist`
- Final location in app bundle: `WhateverClockWidget.appex/Info.plist`

## Additional Notes

This is a common issue when migrating to or using Xcode's newer project format with `PBXFileSystemSynchronizedRootGroup`. The synchronized groups are very convenient but require explicit exceptions for files that need special handling (like Info.plist, entitlements, etc.).
