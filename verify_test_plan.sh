#!/bin/bash

# Test Plan Configuration Verification Script
echo "🔍 Verifying Test Plan Configuration"
echo "===================================="

# Check if test plan exists
if [ -f "PalChiApp.xcodeproj/xcshareddata/xcschemes/AdminSheets.xctestplan" ]; then
    echo "✅ Test plan file exists: AdminSheets.xctestplan"
else
    echo "❌ Test plan file missing"
fi

# Check if scheme exists
if [ -f "PalChiApp.xcodeproj/xcshareddata/xcschemes/PalChiApp.xcscheme" ]; then
    echo "✅ Scheme file exists: PalChiApp.xcscheme"
else
    echo "❌ Scheme file missing"
fi

# Check if test directory exists
if [ -d "PalChiAppTests" ]; then
    echo "✅ Test directory exists: PalChiAppTests"
    echo "   Test files found:"
    ls -la PalChiAppTests/ | grep "\.swift$" | awk '{print "   - " $9}'
else
    echo "❌ Test directory missing"
fi

# Check if configuration report was generated
if [ -f "Test_Plan_Configuration_Report.md" ]; then
    echo "✅ Configuration report exists: Test_Plan_Configuration_Report.md"
else
    echo "❌ Configuration report missing"
fi

echo ""
echo "📋 Configuration Summary:"
echo "========================"
echo "The test plan configuration includes:"
echo "• AdminSheets.xctestplan - Main test plan file"
echo "• Updated PalChiApp.xcscheme - Scheme with test plan reference"
echo "• PalChiAppTests target - Added to project (may need Xcode refresh)"
echo "• Test files properly organized in PalChiAppTests directory"
echo ""
echo "🚀 Next Steps:"
echo "1. Open PalChiApp.xcodeproj in Xcode"
echo "2. Clean Build Folder (⌘⇧K)"
echo "3. Navigate to Test Navigator (⌘6)"
echo "4. Look for 'AdminSheets' test plan"
echo "5. Run tests using the test plan"
echo ""
echo "If the test plan doesn't appear immediately, close and reopen Xcode."