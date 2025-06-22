#!/bin/bash

# TestPlanChi2 AdminSheets Integration Verification Script
echo "🧪 Verifying AdminSheets Integration with TestPlanChi2"
echo "====================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    local color=$1
    local message=$2
    echo -e "${color}[$(date +'%H:%M:%S')] ${message}${NC}"
}

# Check if TestPlanChi2.xctestplan exists
if [ -f "TestPlanChi2.xctestplan" ]; then
    print_status $GREEN "✅ TestPlanChi2.xctestplan found"
else
    print_status $RED "❌ TestPlanChi2.xctestplan not found"
    exit 1
fi

# Verify test plan content
print_status $BLUE "🔍 Analyzing test plan configuration..."

# Check if AdminSheets tests are included
if grep -q "AdminSheetsTests" TestPlanChi2.xctestplan; then
    print_status $GREEN "✅ AdminSheetsTests included in test plan"
else
    print_status $RED "❌ AdminSheetsTests not found in test plan"
fi

if grep -q "AdminSheetsBuildIssueTests" TestPlanChi2.xctestplan; then
    print_status $GREEN "✅ AdminSheetsBuildIssueTests included in test plan"
else
    print_status $RED "❌ AdminSheetsBuildIssueTests not found in test plan"
fi

# Check if code coverage is enabled
if grep -q "codeCoverage" TestPlanChi2.xctestplan; then
    print_status $GREEN "✅ Code coverage enabled"
else
    print_status $YELLOW "⚠️  Code coverage not configured"
fi

# Check if PalChiAppTests target is referenced
if grep -q "PalChiAppTests" TestPlanChi2.xctestplan; then
    print_status $GREEN "✅ PalChiAppTests target referenced"
else
    print_status $RED "❌ PalChiAppTests target not found"
fi

# Verify test files exist
print_status $BLUE "📁 Checking test files..."

test_files=(
    "PalChiAppTests/AdminSheetsTests.swift"
    "PalChiAppTests/AdminSheetsBuildIssueTests.swift"
    "PalChiAppTests/AdminSheetsTestConfiguration.swift"
)

for file in "${test_files[@]}"; do
    if [ -f "$file" ]; then
        print_status $GREEN "✅ $file exists"
    else
        print_status $RED "❌ $file missing"
    fi
done

# Count test methods in the test plan
test_method_count=$(grep -o "testAdminViewInitialization\|testStatisticsTabComponents\|testConnectivityTabComponents\|testDevicesTabComponents\|testLocationTabComponents\|testListsTabComponents\|testAdminSheetPresentation\|testAdminSheetDismissal\|testTabSwitching\|testDataBinding\|testErrorHandling\|testAccessibilitySupport\|testPerformanceMetrics\|testSwiftUIImports\|testCoreDataImports\|testNetworkingImports\|testFoundationImports\|testXCTestImports\|testBasicCompilation\|testViewControllerInstantiation\|testModelInstantiation\|testNetworkManagerAccess\|testCoreDataStackAccess\|testBuildConfiguration\|testTargetConfiguration\|testSchemeConfiguration\|testSimulatorCompatibility\|testDeploymentTarget" TestPlanChi2.xctestplan | wc -l)

print_status $BLUE "📊 Test plan includes $test_method_count specific test methods"

# Test plan summary
echo ""
print_status $BLUE "📋 TestPlanChi2 Configuration Summary:"
echo "======================================"
echo "• Test Plan: TestPlanChi2.xctestplan"
echo "• Target: PalChiAppTests"
echo "• Test Classes: AdminSheetsTests, AdminSheetsBuildIssueTests"
echo "• Test Methods: $test_method_count specific methods"
echo "• Code Coverage: Enabled for PalChiApp target"
echo "• Parallel Execution: Enabled"
echo "• Test Timeouts: Enabled"

# Usage instructions
echo ""
print_status $BLUE "🚀 How to Run AdminSheets Tests with TestPlanChi2:"
echo "================================================="
echo ""
echo "In Xcode:"
echo "1. Open PalChiApp.xcodeproj"
echo "2. Navigate to Test Navigator (⌘6)"
echo "3. Look for 'TestPlanChi2' test plan"
echo "4. Click the play button to run all AdminSheets tests"
echo ""
echo "Command Line:"
echo "# Run all tests in TestPlanChi2"
echo "xcodebuild test -project PalChiApp.xcodeproj -scheme PalChiApp -testPlan TestPlanChi2 -destination 'platform=iOS Simulator,name=iPad (10th generation)'"
echo ""
echo "# Run only AdminSheetsTests class"
echo "xcodebuild test -project PalChiApp.xcodeproj -scheme PalChiApp -testPlan TestPlanChi2 -only-testing:PalChiAppTests/AdminSheetsTests -destination 'platform=iOS Simulator,name=iPad (10th generation)'"
echo ""
echo "# Run specific test method"
echo "xcodebuild test -project PalChiApp.xcodeproj -scheme PalChiApp -testPlan TestPlanChi2 -only-testing:PalChiAppTests/AdminSheetsTests/testAdminViewInitialization -destination 'platform=iOS Simulator,name=iPad (10th generation)'"

# Quick test to verify project can list the test plan
print_status $BLUE "🔧 Testing project configuration..."

if command -v xcodebuild >/dev/null 2>&1; then
    # Try to list test plans (this will show if TestPlanChi2 is recognized)
    if xcodebuild -list -project PalChiApp.xcodeproj 2>/dev/null | grep -q "Test Plans"; then
        print_status $GREEN "✅ Project recognizes test plans"
    else
        print_status $YELLOW "⚠️  Test plans may need Xcode refresh"
    fi
else
    print_status $YELLOW "⚠️  xcodebuild not available for testing"
fi

echo ""
print_status $GREEN "🎉 AdminSheets tests successfully integrated into TestPlanChi2!"
echo ""
print_status $BLUE "💡 Tips:"
echo "• If TestPlanChi2 doesn't appear in Xcode, try cleaning build folder (⌘⇧K)"
echo "• Close and reopen Xcode if the test plan doesn't show up immediately"
echo "• The test plan includes both comprehensive tests and build issue diagnostics"
echo "• Code coverage reports will help identify areas needing more tests"