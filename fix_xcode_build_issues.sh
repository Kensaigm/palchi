#!/bin/bash

# Xcode Build Issue Resolution Script for AdminSheets
# This script addresses common Xcode-specific build issues that don't appear in command line builds

echo "🔧 Xcode Build Issue Resolution for AdminSheets"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}[$(date +'%H:%M:%S')] ${message}${NC}"
}

# Check if we're in the right directory
if [ ! -f "PalChiApp.xcodeproj/project.pbxproj" ]; then
    print_status $RED "ERROR: PalChiApp.xcodeproj not found. Please run this script from the project root."
    exit 1
fi

print_status $BLUE "Starting Xcode build issue resolution..."

# 1. Clean Derived Data
print_status $BLUE "Step 1: Cleaning Derived Data..."
if [ -d ~/Library/Developer/Xcode/DerivedData ]; then
    # Find and remove PalChiApp derived data
    find ~/Library/Developer/Xcode/DerivedData -name "*PalChiApp*" -type d -exec rm -rf {} + 2>/dev/null
    print_status $GREEN "Derived Data cleaned"
else
    print_status $YELLOW "Derived Data directory not found"
fi

# 2. Check and fix scheme configuration
print_status $BLUE "Step 2: Checking scheme configuration..."

# Check if scheme exists
if ! xcodebuild -list -project PalChiApp.xcodeproj | grep -q "PalChiApp"; then
    print_status $YELLOW "PalChiApp scheme not found or not configured properly"
    
    # Try to create a basic scheme configuration
    print_status $BLUE "Attempting to fix scheme configuration..."
    
    # Create xcschemes directory if it doesn't exist
    mkdir -p "PalChiApp.xcodeproj/xcuserdata/$(whoami).xcuserdatad/xcschemes"
    
    # Create a basic scheme file
    cat > "PalChiApp.xcodeproj/xcuserdata/$(whoami).xcuserdatad/xcschemes/PalChiApp.xcscheme" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1600"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "PalChiApp"
               BuildableName = "PalChiApp.app"
               BlueprintName = "PalChiApp"
               ReferencedContainer = "container:PalChiApp.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES">
      <Testables>
         <TestableReference
            skipped = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "PalChiAppTests"
               BuildableName = "PalChiAppTests.xctest"
               BlueprintName = "PalChiAppTests"
               ReferencedContainer = "container:PalChiApp.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "PalChiApp"
            BuildableName = "PalChiApp.app"
            BlueprintName = "PalChiApp"
            ReferencedContainer = "container:PalChiApp.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "PalChiApp"
            BuildableName = "PalChiApp.app"
            BlueprintName = "PalChiApp"
            ReferencedContainer = "container:PalChiApp.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
EOF
    
    print_status $GREEN "Basic scheme configuration created"
else
    print_status $GREEN "Scheme configuration appears to be correct"
fi

# 3. Check for Core Data model issues
print_status $BLUE "Step 3: Checking Core Data model..."
if [ -d "PalChiApp/Data/PalChiDataModel.xcdatamodeld" ]; then
    if [ -z "$(ls -A PalChiApp/Data/PalChiDataModel.xcdatamodeld)" ]; then
        print_status $YELLOW "Core Data model directory is empty"
        
        # Create a basic Core Data model
        print_status $BLUE "Creating basic Core Data model..."
        cat > "PalChiApp/Data/PalChiDataModel.xcdatamodeld/PalChiDataModel.xcdatamodel/contents" << 'EOF'
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<model type="com.apple.IDECoreDataModeler.DataModel" documentVersion="1.0" lastSavedToolsVersion="22758" systemVersion="23F79" minimumToolsVersion="Automatic" sourceLanguage="Swift" userDefinedModelVersionIdentifier="">
    <entity name="Session" representedClassName="Session" syncable="YES" codeGenerationType="class">
        <attribute name="id" optional="YES" attributeType="UUID" usesScalarValueType="NO"/>
        <attribute name="jsonData" optional="YES" attributeType="Binary"/>
        <attribute name="sessionId" optional="YES" attributeType="String"/>
        <attribute name="size" optional="YES" attributeType="Integer 64" defaultValueString="0" usesScalarValueType="YES"/>
        <attribute name="synced" optional="YES" attributeType="Boolean" usesScalarValueType="YES"/>
        <attribute name="syncedAt" optional="YES" attributeType="Date" usesScalarValueType="NO"/>
        <attribute name="timestamp" optional="YES" attributeType="Date" usesScalarValueType="NO"/>
        <attribute name="userId" optional="YES" attributeType="String"/>
    </entity>
</model>
EOF
        print_status $GREEN "Basic Core Data model created"
    else
        print_status $GREEN "Core Data model exists and is not empty"
    fi
else
    print_status $YELLOW "Core Data model directory not found"
fi

# 4. Check for missing asset catalogs
print_status $BLUE "Step 4: Checking asset catalogs..."
if [ ! -d "PalChiApp/Resources/Assets.xcassets" ]; then
    print_status $YELLOW "Assets.xcassets not found, creating basic structure..."
    mkdir -p "PalChiApp/Resources/Assets.xcassets"
    
    # Create Contents.json for Assets.xcassets
    cat > "PalChiApp/Resources/Assets.xcassets/Contents.json" << 'EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
    
    # Create AppIcon.appiconset
    mkdir -p "PalChiApp/Resources/Assets.xcassets/AppIcon.appiconset"
    cat > "PalChiApp/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json" << 'EOF'
{
  "images" : [
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "20x20"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "40x40"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
    print_status $GREEN "Basic asset catalog structure created"
else
    print_status $GREEN "Asset catalog exists"
fi

# 5. Check Colors.xcassets
if [ ! -d "PalChiApp/Resources/Colors.xcassets" ]; then
    print_status $BLUE "Creating Colors.xcassets..."
    mkdir -p "PalChiApp/Resources/Colors.xcassets"
    
    cat > "PalChiApp/Resources/Colors.xcassets/Contents.json" << 'EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
    print_status $GREEN "Colors.xcassets created"
fi

# 6. Validate project structure
print_status $BLUE "Step 5: Validating project structure..."

required_files=(
    "PalChiApp/App/AppDelegate.swift"
    "PalChiApp/App/SceneDelegate.swift"
    "PalChiApp/Controllers/ViewController.swift"
    "PalChiApp/Views/AdminSheets.swift"
    "PalChiApp/Services/AdminManager.swift"
    "PalChiApp/Models/AdminModels.swift"
)

missing_files=()
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -eq 0 ]; then
    print_status $GREEN "All required files are present"
else
    print_status $YELLOW "Missing files detected:"
    for file in "${missing_files[@]}"; do
        echo "  - $file"
    done
fi

# 7. Test the build
print_status $BLUE "Step 6: Testing build..."
if xcodebuild -project PalChiApp.xcodeproj -scheme PalChiApp -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 14,OS=latest' build > /tmp/xcode_build_test.log 2>&1; then
    print_status $GREEN "Build test successful"
else
    print_status $YELLOW "Build test failed - check /tmp/xcode_build_test.log for details"
fi

# 8. Test the tests
print_status $BLUE "Step 7: Testing test configuration..."
if xcodebuild test -project PalChiApp.xcodeproj -scheme PalChiApp -destination 'platform=iOS Simulator,name=iPhone 14,OS=latest' -only-testing:PalChiAppTests > /tmp/xcode_test_test.log 2>&1; then
    print_status $GREEN "Test configuration successful"
else
    print_status $YELLOW "Test configuration failed - check /tmp/xcode_test_test.log for details"
fi

# 9. Generate resolution report
print_status $BLUE "Step 8: Generating resolution report..."

cat > "Xcode_Build_Resolution_Report.md" << EOF
# Xcode Build Issue Resolution Report
Generated on: $(date)

## Actions Taken

1. **Derived Data Cleanup**: Removed old build artifacts
2. **Scheme Configuration**: Checked and fixed scheme setup
3. **Core Data Model**: Verified/created basic model structure
4. **Asset Catalogs**: Ensured proper asset catalog structure
5. **Project Structure**: Validated required files

## Files Created/Modified

- PalChiApp.xcodeproj/xcuserdata/$(whoami).xcuserdatad/xcschemes/PalChiApp.xcscheme
- PalChiApp/Data/PalChiDataModel.xcdatamodeld/PalChiDataModel.xcdatamodel/contents (if missing)
- PalChiApp/Resources/Assets.xcassets/ (if missing)
- PalChiApp/Resources/Colors.xcassets/ (if missing)

## Next Steps

1. **Open Xcode**: Open PalChiApp.xcodeproj in Xcode
2. **Clean Build Folder**: Product → Clean Build Folder (⌘⇧K)
3. **Build Project**: Product → Build (⌘B)
4. **Run Tests**: Product → Test (⌘U)

## If Issues Persist

1. Check the Issue Navigator (⌘5) in Xcode for specific errors
2. Verify all targets are properly configured
3. Check build settings for any custom configurations
4. Review the test logs: /tmp/xcode_build_test.log and /tmp/xcode_test_test.log

## AdminSheets Specific Tests

The following test files have been created to help identify AdminSheets-specific issues:

- PalChiAppTests/AdminSheetsTests.swift
- PalChiAppTests/AdminSheetsBuildIssueTests.swift
- PalChiAppTests/AdminSheetsTestConfiguration.swift

Run these tests individually in Xcode to isolate any remaining issues.
EOF

print_status $GREEN "Resolution report generated: Xcode_Build_Resolution_Report.md"

echo ""
print_status $BLUE "🎉 Xcode Build Issue Resolution Complete!"
echo ""
print_status $BLUE "Next steps:"
echo "  1. Open PalChiApp.xcodeproj in Xcode"
echo "  2. Clean Build Folder (⌘⇧K)"
echo "  3. Build the project (⌘B)"
echo "  4. Run the AdminSheets tests (⌘U)"
echo ""
print_status $BLUE "Check 'Xcode_Build_Resolution_Report.md' for detailed information."