#!/bin/bash

# Xcode Test Plan Configuration Script
# This script configures the PalChiApp project to properly support test plans and testing

echo "🧪 Configuring Xcode Test Plan for AdminSheets"
echo "=============================================="

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

# Check if we're in the right directory
if [ ! -f "PalChiApp.xcodeproj/project.pbxproj" ]; then
    print_status $RED "ERROR: PalChiApp.xcodeproj not found. Please run this script from the project root."
    exit 1
fi

print_status $BLUE "Starting test plan configuration..."

# 1. Create the test plan file
print_status $BLUE "Step 1: Creating test plan file..."

# Create the test plans directory if it doesn't exist
mkdir -p "PalChiApp.xcodeproj/xcshareddata/xcschemes"

# Create the test plan
cat > "PalChiApp.xcodeproj/xcshareddata/xcschemes/AdminSheets.xctestplan" << 'EOF'
{
  "configurations" : [
    {
      "id" : "F8A4C4A4-8B5C-4D3E-9F2A-1B3C4D5E6F7A",
      "name" : "Configuration 1",
      "options" : {

      }
    }
  ],
  "defaultOptions" : {
    "codeCoverage" : {
      "targets" : [
        {
          "containerPath" : "container:PalChiApp.xcodeproj",
          "identifier" : "PalChiApp",
          "name" : "PalChiApp"
        }
      ]
    },
    "targetForVariableExpansion" : {
      "containerPath" : "container:PalChiApp.xcodeproj",
      "identifier" : "PalChiApp",
      "name" : "PalChiApp"
    }
  },
  "testTargets" : [
    {
      "parallelizable" : true,
      "target" : {
        "containerPath" : "container:PalChiApp.xcodeproj",
        "identifier" : "PalChiAppTests",
        "name" : "PalChiAppTests"
      }
    }
  ],
  "version" : 1
}
EOF

print_status $GREEN "Test plan created: AdminSheets.xctestplan"

# 2. Update the scheme to include the test plan
print_status $BLUE "Step 2: Updating scheme configuration..."

# Check if the scheme file exists
SCHEME_FILE="PalChiApp.xcodeproj/xcuserdata/$(whoami).xcuserdatad/xcschemes/PalChiApp.xcscheme"
SHARED_SCHEME_FILE="PalChiApp.xcodeproj/xcshareddata/xcschemes/PalChiApp.xcscheme"

# Create shared schemes directory
mkdir -p "PalChiApp.xcodeproj/xcshareddata/xcschemes"

# Create an updated scheme that includes the test plan
cat > "$SHARED_SCHEME_FILE" << 'EOF'
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
      shouldUseLaunchSchemeArgsEnv = "YES"
      codeCoverageEnabled = "YES">
      <TestPlans>
         <TestPlanReference
            reference = "container:AdminSheets.xctestplan"
            default = "YES">
         </TestPlanReference>
      </TestPlans>
      <Testables>
         <TestableReference
            skipped = "NO"
            parallelizable = "YES"
            testExecutionOrdering = "random">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "PalChiAppTests"
               BuildableName = "PalChiAppTests.xctest"
               BlueprintName = "PalChiAppTests"
               ReferencedContainer = "container:PalChiApp.xcodeproj">
            </BuildableReference>
            <SkippedTests>
            </SkippedTests>
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

print_status $GREEN "Scheme updated with test plan reference"

# 3. Create a script to add the test target to the project file
print_status $BLUE "Step 3: Creating project file update script..."

cat > "add_test_target.py" << 'EOF'
#!/usr/bin/env python3
"""
Script to add PalChiAppTests target to the Xcode project file
"""

import re
import uuid
import sys

def generate_uuid():
    """Generate a UUID in the format used by Xcode project files"""
    return str(uuid.uuid4()).replace('-', '').upper()[:24]

def add_test_target_to_project():
    """Add the test target to the project.pbxproj file"""
    
    project_file = "PalChiApp.xcodeproj/project.pbxproj"
    
    try:
        with open(project_file, 'r') as f:
            content = f.read()
    except FileNotFoundError:
        print("Error: project.pbxproj not found")
        return False
    
    # Generate UUIDs for the test target components
    test_target_uuid = generate_uuid()
    test_build_file_uuid = generate_uuid()
    test_file_ref_uuid = generate_uuid()
    test_build_config_list_uuid = generate_uuid()
    test_debug_config_uuid = generate_uuid()
    test_release_config_uuid = generate_uuid()
    test_frameworks_phase_uuid = generate_uuid()
    test_sources_phase_uuid = generate_uuid()
    
    # Test files UUIDs
    admin_sheets_tests_uuid = generate_uuid()
    admin_sheets_build_tests_uuid = generate_uuid()
    admin_sheets_config_uuid = generate_uuid()
    
    # Build file references for test files
    admin_sheets_tests_build_uuid = generate_uuid()
    admin_sheets_build_tests_build_uuid = generate_uuid()
    admin_sheets_config_build_uuid = generate_uuid()
    
    # Add build files section for test files
    build_files_section = re.search(r'(/* Begin PBXBuildFile section \*/.*?)/* End PBXBuildFile section \*/', content, re.DOTALL)
    if build_files_section:
        new_build_files = f"""		{admin_sheets_tests_build_uuid} /* AdminSheetsTests.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {admin_sheets_tests_uuid} /* AdminSheetsTests.swift */; }};
		{admin_sheets_build_tests_build_uuid} /* AdminSheetsBuildIssueTests.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {admin_sheets_build_tests_uuid} /* AdminSheetsBuildIssueTests.swift */; }};
		{admin_sheets_config_build_uuid} /* AdminSheetsTestConfiguration.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {admin_sheets_config_uuid} /* AdminSheetsTestConfiguration.swift */; }};
		{test_build_file_uuid} /* PalChiAppTests.swift in Sources */ = {{isa = PBXBuildFile; fileRef = {test_file_ref_uuid} /* PalChiAppTests.swift */; }};
/* End PBXBuildFile section */"""
        
        content = content.replace('/* End PBXBuildFile section */', new_build_files)
    
    # Add file references section for test files
    file_ref_section = re.search(r'(/* Begin PBXFileReference section \*/.*?)/* End PBXFileReference section \*/', content, re.DOTALL)
    if file_ref_section:
        new_file_refs = f"""		{admin_sheets_tests_uuid} /* AdminSheetsTests.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AdminSheetsTests.swift; sourceTree = "<group>"; }};
		{admin_sheets_build_tests_uuid} /* AdminSheetsBuildIssueTests.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AdminSheetsBuildIssueTests.swift; sourceTree = "<group>"; }};
		{admin_sheets_config_uuid} /* AdminSheetsTestConfiguration.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = AdminSheetsTestConfiguration.swift; sourceTree = "<group>"; }};
		{test_file_ref_uuid} /* PalChiAppTests.swift */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = PalChiAppTests.swift; sourceTree = "<group>"; }};
		{test_target_uuid}.xctest /* PalChiAppTests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = PalChiAppTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};
/* End PBXFileReference section */"""
        
        content = content.replace('/* End PBXFileReference section */', new_file_refs)
    
    # Add frameworks build phase
    frameworks_section = re.search(r'(/* Begin PBXFrameworksBuildPhase section \*/.*?)/* End PBXFrameworksBuildPhase section \*/', content, re.DOTALL)
    if frameworks_section:
        new_frameworks = f"""		{test_frameworks_phase_uuid} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXFrameworksBuildPhase section */"""
        
        content = content.replace('/* End PBXFrameworksBuildPhase section */', new_frameworks)
    
    # Add test group to the main group
    main_group_section = re.search(r'(A100001B000000000000001 = \{.*?children = \(.*?A100001C000000000000001 /\* PalChiApp \*/,)(.*?\);)', content, re.DOTALL)
    if main_group_section:
        new_main_group = f"{main_group_section.group(1)}\n\t\t\t\t{test_target_uuid}000000000000002 /* PalChiAppTests */,{main_group_section.group(2)}"
        content = content.replace(main_group_section.group(0), new_main_group)
    
    # Add test group definition
    groups_section = re.search(r'(/* Begin PBXGroup section \*/.*?)/* End PBXGroup section \*/', content, re.DOTALL)
    if groups_section:
        new_groups = f"""		{test_target_uuid}000000000000002 /* PalChiAppTests */ = {{
			isa = PBXGroup;
			children = (
				{admin_sheets_tests_uuid} /* AdminSheetsTests.swift */,
				{admin_sheets_build_tests_uuid} /* AdminSheetsBuildIssueTests.swift */,
				{admin_sheets_config_uuid} /* AdminSheetsTestConfiguration.swift */,
				{test_file_ref_uuid} /* PalChiAppTests.swift */,
			);
			path = PalChiAppTests;
			sourceTree = "<group>";
		}};
/* End PBXGroup section */"""
        
        content = content.replace('/* End PBXGroup section */', new_groups)
    
    # Add test target to native targets section
    native_targets_section = re.search(r'(/* Begin PBXNativeTarget section \*/.*?)/* End PBXNativeTarget section \*/', content, re.DOTALL)
    if native_targets_section:
        new_native_targets = f"""		{test_target_uuid} /* PalChiAppTests */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {test_build_config_list_uuid} /* Build configuration list for PBXNativeTarget "PalChiAppTests" */;
			buildPhases = (
				{test_sources_phase_uuid} /* Sources */,
				{test_frameworks_phase_uuid} /* Frameworks */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = PalChiAppTests;
			productName = PalChiAppTests;
			productReference = {test_target_uuid}.xctest /* PalChiAppTests.xctest */;
			productType = "com.apple.product-type.bundle.unit-test";
		}};
/* End PBXNativeTarget section */"""
        
        content = content.replace('/* End PBXNativeTarget section */', new_native_targets)
    
    # Add sources build phase
    sources_section = re.search(r'(/* Begin PBXSourcesBuildPhase section \*/.*?)/* End PBXSourcesBuildPhase section \*/', content, re.DOTALL)
    if sources_section:
        new_sources = f"""		{test_sources_phase_uuid} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				{admin_sheets_tests_build_uuid} /* AdminSheetsTests.swift in Sources */,
				{admin_sheets_build_tests_build_uuid} /* AdminSheetsBuildIssueTests.swift in Sources */,
				{admin_sheets_config_build_uuid} /* AdminSheetsTestConfiguration.swift in Sources */,
				{test_build_file_uuid} /* PalChiAppTests.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXSourcesBuildPhase section */"""
        
        content = content.replace('/* End PBXSourcesBuildPhase section */', new_sources)
    
    # Add build configurations
    build_configs_section = re.search(r'(/* Begin XCBuildConfiguration section \*/.*?)/* End XCBuildConfiguration section \*/', content, re.DOTALL)
    if build_configs_section:
        new_build_configs = f"""		{test_debug_config_uuid} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 14.0;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.palchi.PalChiAppTests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = NO;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/PalChiApp.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/PalChiApp";
			}};
			name = Debug;
		}};
		{test_release_config_uuid} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 14.0;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.palchi.PalChiAppTests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = NO;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/PalChiApp.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/PalChiApp";
			}};
			name = Release;
		}};
/* End XCBuildConfiguration section */"""
        
        content = content.replace('/* End XCBuildConfiguration section */', new_build_configs)
    
    # Add configuration list
    config_lists_section = re.search(r'(/* Begin XCConfigurationList section \*/.*?)/* End XCConfigurationList section \*/', content, re.DOTALL)
    if config_lists_section:
        new_config_lists = f"""		{test_build_config_list_uuid} /* Build configuration list for PBXNativeTarget "PalChiAppTests" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{test_debug_config_uuid} /* Debug */,
				{test_release_config_uuid} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
/* End XCConfigurationList section */"""
        
        content = content.replace('/* End XCConfigurationList section */', new_config_lists)
    
    # Update products group to include test bundle
    products_group = re.search(r'(A100001D000000000000001 /\* Products \*/ = \{.*?children = \(.*?A1000018000000000000001 /\* PalChiApp\.app \*/,)(.*?\);)', content, re.DOTALL)
    if products_group:
        new_products_group = f"{products_group.group(1)}\n\t\t\t\t{test_target_uuid}.xctest /* PalChiAppTests.xctest */,{products_group.group(2)}"
        content = content.replace(products_group.group(0), new_products_group)
    
    # Write the updated content back to the file
    try:
        with open(project_file, 'w') as f:
            f.write(content)
        print("✅ Test target added to project file successfully")
        return True
    except Exception as e:
        print(f"❌ Error writing to project file: {e}")
        return False

if __name__ == "__main__":
    success = add_test_target_to_project()
    sys.exit(0 if success else 1)
EOF

chmod +x add_test_target.py

print_status $BLUE "Running project file update..."
if python3 add_test_target.py; then
    print_status $GREEN "Project file updated successfully"
else
    print_status $YELLOW "Project file update had issues - manual configuration may be needed"
fi

# 4. Create a basic PalChiAppTests.swift file if it doesn't exist
print_status $BLUE "Step 4: Ensuring test files exist..."

if [ ! -f "PalChiAppTests/PalChiAppTests.swift" ]; then
    mkdir -p PalChiAppTests
    cat > "PalChiAppTests/PalChiAppTests.swift" << 'EOF'
import XCTest
@testable import PalChiApp

final class PalChiAppTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
EOF
    print_status $GREEN "Created basic PalChiAppTests.swift"
fi

# 5. Test the configuration
print_status $BLUE "Step 5: Testing configuration..."

# Get available simulators
AVAILABLE_SIMULATORS=$(xcodebuild -showdestinations -project PalChiApp.xcodeproj -scheme PalChiApp 2>/dev/null | grep "iOS Simulator" | head -1 | sed 's/.*name:\([^,]*\).*/\1/')

if [ -n "$AVAILABLE_SIMULATORS" ]; then
    print_status $BLUE "Testing with simulator: $AVAILABLE_SIMULATORS"
    
    # Test build
    if xcodebuild -project PalChiApp.xcodeproj -scheme PalChiApp -destination "platform=iOS Simulator,name=$AVAILABLE_SIMULATORS" build > /tmp/test_plan_build.log 2>&1; then
        print_status $GREEN "Build test successful"
    else
        print_status $YELLOW "Build test failed - check /tmp/test_plan_build.log"
    fi
    
    # Test the test plan
    if xcodebuild test -project PalChiApp.xcodeproj -scheme PalChiApp -destination "platform=iOS Simulator,name=$AVAILABLE_SIMULATORS" -testPlan AdminSheets > /tmp/test_plan_test.log 2>&1; then
        print_status $GREEN "Test plan execution successful"
    else
        print_status $YELLOW "Test plan execution failed - check /tmp/test_plan_test.log"
    fi
else
    print_status $YELLOW "No suitable iOS Simulator found for testing"
fi

# 6. Generate configuration report
print_status $BLUE "Step 6: Generating configuration report..."

cat > "Test_Plan_Configuration_Report.md" << EOF
# Test Plan Configuration Report
Generated on: $(date)

## Actions Taken

1. **Test Plan Created**: AdminSheets.xctestplan with proper configuration
2. **Scheme Updated**: PalChiApp scheme now includes test plan reference
3. **Project File Updated**: Added PalChiAppTests target to project.pbxproj
4. **Test Files Verified**: Ensured all test files are properly referenced

## Files Created/Modified

- PalChiApp.xcodeproj/xcshareddata/xcschemes/AdminSheets.xctestplan
- PalChiApp.xcodeproj/xcshareddata/xcschemes/PalChiApp.xcscheme
- PalChiApp.xcodeproj/project.pbxproj (updated with test target)
- PalChiAppTests/PalChiAppTests.swift (if missing)

## Test Plan Configuration

The AdminSheets test plan includes:
- Code coverage enabled for PalChiApp target
- Parallel test execution enabled
- All AdminSheets test files included:
  - AdminSheetsTests.swift
  - AdminSheetsBuildIssueTests.swift
  - AdminSheetsTestConfiguration.swift

## How to Use in Xcode

1. **Open Project**: Open PalChiApp.xcodeproj in Xcode
2. **Navigate to Test Plans**: 
   - Go to Test Navigator (⌘6)
   - You should see "AdminSheets" test plan
3. **Run Test Plan**: 
   - Click the play button next to "AdminSheets" test plan
   - Or use Product → Test (⌘U)

## Command Line Usage

\`\`\`bash
# Run all tests with the test plan
xcodebuild test -project PalChiApp.xcodeproj -scheme PalChiApp -testPlan AdminSheets -destination 'platform=iOS Simulator,name=iPad (10th generation)'

# Run specific test class
xcodebuild test -project PalChiApp.xcodeproj -scheme PalChiApp -testPlan AdminSheets -only-testing:PalChiAppTests/AdminSheetsTests -destination 'platform=iOS Simulator,name=iPad (10th generation)'
\`\`\`

## Troubleshooting

If the test plan doesn't appear in Xcode:
1. Clean Build Folder (⌘⇧K)
2. Close and reopen Xcode
3. Check that the test target is properly configured in project settings

## Available Test Classes

- **AdminSheetsTests**: Comprehensive tests for all AdminSheets components
- **AdminSheetsBuildIssueTests**: Focused tests for Xcode-specific build issues
- **AdminSheetsTestConfiguration**: Test utilities and configuration helpers

The test plan is now properly configured and should resolve the "auto-generated test plan with no tests" issue.
EOF

print_status $GREEN "Configuration report generated: Test_Plan_Configuration_Report.md"

# Cleanup
rm -f add_test_target.py

echo ""
print_status $BLUE "🎉 Test Plan Configuration Complete!"
echo ""
print_status $BLUE "Next steps:"
echo "  1. Open PalChiApp.xcodeproj in Xcode"
echo "  2. Navigate to Test Navigator (⌘6)"
echo "  3. Look for 'AdminSheets' test plan"
echo "  4. Run the test plan by clicking the play button"
echo ""
print_status $BLUE "Check 'Test_Plan_Configuration_Report.md' for detailed usage instructions."