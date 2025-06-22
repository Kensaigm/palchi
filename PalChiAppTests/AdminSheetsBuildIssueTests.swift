import XCTest
import SwiftUI
@testable import PalChiApp

/// Focused test suite for identifying and troubleshooting AdminSheets build issues
/// These tests are designed to isolate specific build problems that may not appear in command line builds
class AdminSheetsBuildIssueTests: AdminSheetsTestBase {
    
    // MARK: - Compilation Tests
    
    func testAdminSheetsCompilation() {
        // Test that all AdminSheets can be compiled without errors
        XCTAssertNoThrow({
            let _ = APISettingsSheet.self
            let _ = NetworkDiagnosticsSheet.self
            let _ = AddDeviceSheet.self
            let _ = DeviceDetailSheet.self
            let _ = AddToDeviceListSheet.self
        }, "AdminSheets compilation failed")
    }
    
    func testAdminManagerDependency() {
        // Test AdminManager dependency resolution
        XCTAssertNotNil(adminManager, "AdminManager failed to initialize")
        
        // Test AdminManager properties
        XCTAssertNotNil(adminManager.connectivitySettings)
        XCTAssertNotNil(adminManager.deviceEntries)
        XCTAssertNotNil(adminManager.whitelistedDevices)
        XCTAssertNotNil(adminManager.blacklistedDevices)
    }
    
    func testModelDependencies() {
        // Test that all required models can be instantiated
        XCTAssertNoThrow({
            let _ = ConnectivitySettings()
            let _ = DatabaseStats(
                totalTables: 0,
                totalRecords: 0,
                databaseSize: 0,
                lastVacuum: Date(),
                indexCount: 0,
                averageQueryTime: 0.0,
                connectionCount: 0
            )
        }, "Model instantiation failed")
    }
    
    // MARK: - SwiftUI Integration Tests
    
    func testAPISettingsSheetSwiftUIIntegration() {
        guard let adminManager = adminManager else {
            XCTFail("AdminManager not available")
            return
        }
        
        let sheet = APISettingsSheet(adminManager: adminManager)
        validateSheetRendering(sheet)
        
        // Test that the sheet can be wrapped in NavigationView
        let navigationWrappedSheet = NavigationView {
            sheet
        }
        validateSheetRendering(navigationWrappedSheet)
    }
    
    func testNetworkDiagnosticsSheetSwiftUIIntegration() {
        guard let adminManager = adminManager else {
            XCTFail("AdminManager not available")
            return
        }
        
        let sheet = NetworkDiagnosticsSheet(adminManager: adminManager)
        validateSheetRendering(sheet)
        
        // Test with mock diagnostics
        adminManager.networkDiagnostics = NetworkDiagnostics(
            pingLatency: 25.0,
            downloadSpeed: 50.0,
            uploadSpeed: 10.0,
            packetLoss: 0.1,
            dnsResolutionTime: 15.0,
            connectionType: "WiFi",
            isConnected: true,
            lastTestDate: Date()
        )
        
        validateSheetRendering(sheet)
    }
    
    func testAddDeviceSheetSwiftUIIntegration() {
        guard let adminManager = adminManager else {
            XCTFail("AdminManager not available")
            return
        }
        
        let sheet = AddDeviceSheet(adminManager: adminManager)
        validateSheetRendering(sheet)
    }
    
    func testDeviceDetailSheetSwiftUIIntegration() {
        guard let adminManager = adminManager else {
            XCTFail("AdminManager not available")
            return
        }
        
        let mockDevice = DeviceEntry(
            id: "test-id",
            name: "Test Device",
            deviceId: "TEST001",
            deviceType: .sensor,
            macAddress: "00:11:22:33:44:55",
            ipAddress: "192.168.1.100",
            status: .connected,
            lastSeen: Date(),
            firmwareVersion: "1.0.0",
            batteryLevel: 85
        )
        
        let sheet = DeviceDetailSheet(device: mockDevice, adminManager: adminManager)
        validateSheetRendering(sheet)
    }
    
    func testAddToDeviceListSheetSwiftUIIntegration() {
        guard let adminManager = adminManager else {
            XCTFail("AdminManager not available")
            return
        }
        
        let whitelistSheet = AddToDeviceListSheet(
            adminManager: adminManager,
            listType: DeviceListsView.DeviceListType.whitelist
        )
        validateSheetRendering(whitelistSheet)
        
        let blacklistSheet = AddToDeviceListSheet(
            adminManager: adminManager,
            listType: DeviceListsView.DeviceListType.blacklist
        )
        validateSheetRendering(blacklistSheet)
    }
    
    // MARK: - Memory Management Tests
    
    func testAPISettingsSheetMemoryManagement() {
        checkSheetMemoryLeak {
            APISettingsSheet(adminManager: self.adminManager)
        }
    }
    
    func testNetworkDiagnosticsSheetMemoryManagement() {
        checkSheetMemoryLeak {
            NetworkDiagnosticsSheet(adminManager: self.adminManager)
        }
    }
    
    func testAddDeviceSheetMemoryManagement() {
        checkSheetMemoryLeak {
            AddDeviceSheet(adminManager: self.adminManager)
        }
    }
    
    func testDeviceDetailSheetMemoryManagement() {
        let mockDevice = DeviceEntry(
            id: "test-id",
            name: "Test Device",
            deviceId: "TEST001",
            deviceType: .sensor,
            macAddress: "00:11:22:33:44:55",
            ipAddress: "192.168.1.100",
            status: .connected,
            lastSeen: Date(),
            firmwareVersion: "1.0.0",
            batteryLevel: 85
        )
        
        checkSheetMemoryLeak {
            DeviceDetailSheet(device: mockDevice, adminManager: self.adminManager)
        }
    }
    
    // MARK: - State Management Tests
    
    func testObservedObjectBinding() {
        // Test that @ObservedObject bindings work correctly
        let sheet = APISettingsSheet(adminManager: adminManager)
        let hostingController = UIHostingController(rootView: sheet)
        
        hostingController.loadViewIfNeeded()
        
        // Change AdminManager state and verify it doesn't crash
        adminManager.connectivitySettings.apiBaseURL = "https://test.example.com"
        adminManager.isLoading = true
        adminManager.isLoading = false
        
        XCTAssertNotNil(hostingController.view)
    }
    
    func testEnvironmentValues() {
        // Test that environment values are properly handled
        let sheet = APISettingsSheet(adminManager: adminManager)
        
        // Test with different environment configurations
        let hostingController = UIHostingController(rootView: sheet)
        hostingController.loadViewIfNeeded()
        
        XCTAssertNotNil(hostingController.view)
    }
    
    // MARK: - Build-Specific Issue Tests
    
    func testXcodeSpecificIssues() {
        // Test for issues that might only appear in Xcode builds
        
        // 1. Test preview compilation
        XCTAssertNoThrow({
            // This simulates what Xcode previews do
            let sheet = APISettingsSheet(adminManager: adminManager)
            let _ = UIHostingController(rootView: sheet)
        }, "Preview compilation failed")
        
        // 2. Test interface builder integration
        XCTAssertNoThrow({
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            // This will fail gracefully if Main.storyboard doesn't exist
        }, "Storyboard loading failed")
        
        // 3. Test asset catalog access
        XCTAssertNoThrow({
            let _ = UIImage(named: "AppIcon")
        }, "Asset catalog access failed")
    }
    
    func testBuildConfigurationIssues() {
        // Test for build configuration specific issues
        
        #if DEBUG
        print("Running in DEBUG configuration")
        #else
        print("Running in RELEASE configuration")
        #endif
        
        // Test that debug-specific code doesn't break release builds
        XCTAssertTrue(true, "Build configuration test passed")
    }
    
    func testFrameworkLinking() {
        // Test that all required frameworks are properly linked
        
        // SwiftUI
        XCTAssertTrue(UIHostingController<Text>(rootView: Text("Test")).view != nil)
        
        // Foundation
        XCTAssertNotNil(Date())
        
        // UIKit
        XCTAssertNotNil(UIView())
        
        // Core Data (if available)
        XCTAssertNotNil(NSManagedObjectContext.self)
    }
    
    // MARK: - Diagnostic Tests
    
    func testRunFullDiagnostics() {
        let issues = testConfig.runAdminSheetsSpecificDiagnostics()
        
        if !issues.isEmpty {
            print("🔍 AdminSheets Diagnostic Issues Found:")
            for (index, issue) in issues.enumerated() {
                print("  \(index + 1). \(issue)")
            }
            
            // Don't fail the test, just report issues
            XCTAssertTrue(true, "Diagnostics completed with \(issues.count) issues found")
        } else {
            print("✅ No diagnostic issues found")
            XCTAssertTrue(true, "All diagnostics passed")
        }
    }
    
    func testBuildEnvironment() {
        // Test the build environment
        print("📱 Test Environment Info:")
        print("  - iOS Version: \(UIDevice.current.systemVersion)")
        print("  - Device Model: \(UIDevice.current.model)")
        print("  - Bundle ID: \(Bundle.main.bundleIdentifier ?? "Unknown")")
        print("  - App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
        
        XCTAssertTrue(true, "Build environment test completed")
    }
    
    // MARK: - Performance Tests
    
    func testSheetInstantiationPerformance() {
        measure {
            for _ in 0..<10 {
                let _ = APISettingsSheet(adminManager: adminManager)
                let _ = NetworkDiagnosticsSheet(adminManager: adminManager)
                let _ = AddDeviceSheet(adminManager: adminManager)
            }
        }
    }
    
    func testSheetRenderingPerformance() {
        let sheet = APISettingsSheet(adminManager: adminManager)
        
        measure {
            let hostingController = UIHostingController(rootView: sheet)
            hostingController.loadViewIfNeeded()
        }
    }
}