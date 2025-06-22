#!/bin/bash

# Quick validation script for AdminSheets test files
echo "🔍 Validating AdminSheets test files..."

# Check if test files exist
test_files=(
    "PalChiAppTests/AdminSheetsTests.swift"
    "PalChiAppTests/AdminSheetsTestConfiguration.swift"
    "PalChiAppTests/AdminSheetsBuildIssueTests.swift"
)

for file in "${test_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
        
        # Basic syntax check
        if swiftc -parse "$file" 2>/dev/null; then
            echo "  ✅ Syntax valid"
        else
            echo "  ❌ Syntax issues detected"
        fi
        
        # Check for required imports
        if grep -q "import XCTest" "$file"; then
            echo "  ✅ XCTest import found"
        else
            echo "  ⚠️  XCTest import missing"
        fi
        
        if grep -q "@testable import PalChiApp" "$file"; then
            echo "  ✅ PalChiApp testable import found"
        else
            echo "  ⚠️  PalChiApp testable import missing"
        fi
        
    else
        echo "❌ $file missing"
    fi
    echo ""
done

# Check if main app files exist
app_files=(
    "PalChiApp/Views/AdminSheets.swift"
    "PalChiApp/Services/AdminManager.swift"
    "PalChiApp/Models/AdminModels.swift"
)

echo "📱 Checking main app files..."
for file in "${app_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
    fi
done

echo ""
echo "🎯 Quick Test Validation Complete"
echo "Run './run_adminsheets_diagnostics.sh' for full diagnostics"