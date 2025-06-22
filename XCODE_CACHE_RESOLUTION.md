# Xcode IDE Cache Issue - Resolution Steps

## Problem
Command line builds succeed with iOS 15.0 deployment target, but Xcode IDE still shows `@available` errors for iOS 15.0+ features like `@Environment(\.dismiss)`.

## Root Cause
Xcode IDE is using cached build settings and hasn't recognized the updated deployment target from iOS 13.0 to 15.0.

## Resolution Steps

### Step 1: Close Xcode Completely
- Quit Xcode entirely (Cmd+Q)
- Make sure no Xcode processes are running

### Step 2: Clear Xcode Caches
Run these commands in Terminal:

```bash
# Clear derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/PalChiApp-*

# Clear Xcode caches
rm -rf ~/Library/Caches/com.apple.dt.Xcode

# Clear module cache
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex

# Clear Swift package manager cache (if using SPM)
rm -rf ~/Library/Caches/org.swift.swiftpm
```

### Step 3: Clean Project Directory
```bash
cd /path/to/PalChi
rm -rf .build
rm -rf Package.resolved
```

### Step 4: Reopen and Rebuild
1. Open Xcode
2. Open the PalChiApp.xcodeproj project
3. Product → Clean Build Folder (Cmd+Shift+K)
4. Product → Build (Cmd+B)

### Step 5: Verify Settings in Xcode
1. Select the project in Navigator
2. Select the PalChiApp target
3. Go to Build Settings
4. Search for "iOS Deployment Target"
5. Verify it shows 15.0 for all configurations

## Alternative: Force Xcode to Recognize Changes
If the above doesn't work, try:

1. In Xcode, select the project
2. Change deployment target to 14.0 temporarily
3. Build (it should fail)
4. Change back to 15.0
5. Build again

## Verification
- No `@available` warnings for iOS 15.0+ features
- `@Environment(\.dismiss)` compiles without errors
- All Swift concurrency features work properly

## Files Affected
The following SwiftUI files use iOS 15.0+ features:
- `PalChiApp/Views/AdminSheets.swift` - Uses `@Environment(\.dismiss)`
- `PalChiApp/Views/AdminView.swift` - Uses `@Environment(\.dismiss)`

These should compile without errors once Xcode recognizes the iOS 15.0 deployment target.