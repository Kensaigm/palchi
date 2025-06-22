#!/bin/bash

# AdminSheets Test Runner Script
# This script helps identify build issues that appear in Xcode but not in command line builds

set -e

echo "🧪 AdminSheets Build Issue Diagnostic Script"
echo "============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "PalChiApp.xcodeproj/project.pbxproj" ]; then
    print_error "Not in PalChi project directory. Please run from project root."
    exit 1
fi

print_status "Starting AdminSheets build diagnostics..."

# 1. Check Xcode version
print_status "Checking Xcode version..."
xcode_version=$(xcodebuild -version | head -n 1)
echo "  $xcode_version"

# 2. Check iOS SDK version
print_status "Checking iOS SDK..."
ios_sdk=$(xcodebuild -showsdks | grep iphoneos | tail -n 1)
echo "  $ios_sdk"

# 3. Clean build folder
print_status "Cleaning build folder..."
xcodebuild clean -project PalChiApp.xcodeproj -scheme PalChiApp -configuration Debug

# 4. Check for Swift compilation issues
print_status "Testing Swift compilation..."
if xcodebuild -project PalChiApp.xcodeproj -scheme PalChiApp -configuration Debug -sdk iphonesimulator -arch x86_64 build-for-testing 2>&1 | tee build_log.txt; then
    print_success "Swift compilation successful"
else
    print_error "Swift compilation failed"
    echo "Check build_log.txt for details"
fi

# 5. Run specific AdminSheets tests
print_status "Running AdminSheets specific tests..."

# Test compilation of individual files
print_status "Testing individual file compilation..."

# Check AdminSheets.swift
if swiftc -parse PalChiApp/Views/AdminSheets.swift -I . 2>/dev/null; then
    print_success "AdminSheets.swift syntax is valid"
else
    print_warning "AdminSheets.swift has syntax issues"
fi

# Check AdminManager.swift
if swiftc -parse PalChiApp/Services/AdminManager.swift -I . 2>/dev/null; then
    print_success "AdminManager.swift syntax is valid"
else
    print_warning "AdminManager.swift has syntax issues"
fi

# Check AdminModels.swift
if swiftc -parse PalChiApp/Models/AdminModels.swift -I . 2>/dev/null; then
    print_success "AdminModels.swift syntax is valid"
else
    print_warning "AdminModels.swift has syntax issues"
fi

# 6. Run unit tests specifically for AdminSheets
print_status "Running AdminSheets unit tests..."
if xcodebuild test -project PalChiApp.xcodeproj -scheme PalChiApp -destination 'platform=iOS Simulator,name=iPhone 14,OS=latest' -only-testing:PalChiAppTests/AdminSheetsTests 2>&1 | tee test_log.txt; then
    print_success "AdminSheets tests passed"
else
    print_warning "Some AdminSheets tests failed - check test_log.txt"
fi

# 7. Check for common build issues
print_status "Checking for common build issues..."

# Check for missing imports
print_status "Checking imports..."
if grep -r "import SwiftUI" PalChiApp/Views/AdminSheets.swift > /dev/null; then
    print_success "SwiftUI import found"
else
    print_error "SwiftUI import missing"
fi

if grep -r "import Foundation" PalChiApp/Services/AdminManager.swift > /dev/null; then
    print_success "Foundation import found"
else
    print_error "Foundation import missing"
fi

# Check for circular dependencies
print_status "Checking for circular dependencies..."
# This is a simplified check - in a real scenario you'd want more sophisticated dependency analysis
if grep -r "AdminManager" PalChiApp/Views/AdminSheets.swift > /dev/null && grep -r "AdminSheets" PalChiApp/Services/AdminManager.swift > /dev/null; then
    print_warning "Potential circular dependency detected between AdminManager and AdminSheets"
else
    print_success "No obvious circular dependencies found"
fi

# 8. Check Core Data model
print_status "Checking Core Data model..."
if [ -f "PalChiApp/Data/PalChiDataModel.xcdatamodeld" ]; then
    print_success "Core Data model found"
else
    print_warning "Core Data model not found or empty"
fi

# 9. Check for asset issues
print_status "Checking assets..."
if [ -d "PalChiApp/Resources/Assets.xcassets" ]; then
    print_success "Assets.xcassets found"
else
    print_warning "Assets.xcassets not found or empty"
fi

# 10. Generate diagnostic report
print_status "Generating diagnostic report..."
cat > AdminSheets_Diagnostic_Report.md << EOF
# AdminSheets Build Diagnostic Report
Generated on: $(date)

## Environment
- Xcode Version: $xcode_version
- iOS SDK: $ios_sdk
- macOS Version: $(sw_vers -productVersion)

## Build Status
$(if [ -f build_log.txt ]; then echo "Build log available in build_log.txt"; else echo "No build log generated"; fi)

## Test Status
$(if [ -f test_log.txt ]; then echo "Test log available in test_log.txt"; else echo "No test log generated"; fi)

## Files Checked
- AdminSheets.swift: $(if swiftc -parse PalChiApp/Views/AdminSheets.swift -I . 2>/dev/null; then echo "✅ Valid"; else echo "❌ Issues"; fi)
- AdminManager.swift: $(if swiftc -parse PalChiApp/Services/AdminManager.swift -I . 2>/dev/null; then echo "✅ Valid"; else echo "❌ Issues"; fi)
- AdminModels.swift: $(if swiftc -parse PalChiApp/Models/AdminModels.swift -I . 2>/dev/null; then echo "✅ Valid"; else echo "❌ Issues"; fi)

## Recommendations
1. If build fails in Xcode but not command line:
   - Clean Derived Data: ~/Library/Developer/Xcode/DerivedData
   - Restart Xcode
   - Check for Xcode-specific build settings

2. If tests fail:
   - Check test_log.txt for specific failures
   - Verify all dependencies are properly linked
   - Check for iOS version compatibility

3. If syntax issues found:
   - Review the specific files mentioned above
   - Check for missing imports or circular dependencies

## Next Steps
- Review build_log.txt and test_log.txt for detailed error messages
- Run individual test cases to isolate specific issues
- Check Xcode's Issue Navigator for additional build warnings
EOF

print_success "Diagnostic report generated: AdminSheets_Diagnostic_Report.md"

# 11. Final summary
echo ""
echo "🏁 Diagnostic Summary"
echo "===================="
print_status "Diagnostic complete. Check the following files for details:"
echo "  - AdminSheets_Diagnostic_Report.md (summary)"
echo "  - build_log.txt (build details)"
echo "  - test_log.txt (test details)"
echo ""
print_status "To run individual tests:"
echo "  xcodebuild test -project PalChiApp.xcodeproj -scheme PalChiApp -destination 'platform=iOS Simulator,name=iPhone 14,OS=latest' -only-testing:PalChiAppTests/AdminSheetsTests/testSpecificTest"
echo ""
print_status "To debug in Xcode:"
echo "  1. Open PalChiApp.xcodeproj"
echo "  2. Navigate to Test Navigator (⌘6)"
echo "  3. Run AdminSheetsTests or AdminSheetsBuildIssueTests"
echo "  4. Check Issue Navigator (⌘5) for build errors"

# Clean up temporary files (optional)
# rm -f build_log.txt test_log.txt

print_success "AdminSheets diagnostic script completed!"