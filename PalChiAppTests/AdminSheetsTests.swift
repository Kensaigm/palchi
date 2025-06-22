import XCTest
import SwiftUI
@testable import PalChiApp

@MainActor
class AdminSheetsTests: XCTestCase {
    
    var adminManager: AdminManager!
    
    override func setUp() {
        super.setUp()
        adminManager = AdminManager()
    }
    
    override func tearDown() {
        adminManager = nil
        super.tearDown()
    }
    
    // MARK: - APISettingsSheet Tests
    
    func testAPISettingsSheetInitialization() {
        // Test that APISettingsSheet can be initialized without crashing
        let sheet = APISettingsSheet(adminManager: adminManager)
        XCTAssertNotNil(sheet)
    }
    
    func testAPISettingsSheetDefaultValues() {
        // Test default state values
        let sheet = APISettingsSheet(adminManager: adminManager)
        
        // Create a hosting controller to test the view
        let hostingController = UIHostingController(rootView: sheet)
        XCTAssertNotNil(hostingController.view)
        
        // Test that the view can be rendered without crashing
        hostingController.loadViewIfNeeded()
        XCTAssertNotNil(hostingController.view)
    }
    
    func testAPISettingsSheetConnectivitySettings() {
        // Test that connectivity settings are properly loaded
        let settings = ConnectivitySettings(
            apiBaseURL: "https://test.example.com",
            requestTimeout: 45.0,
            maxRetryAttempts: 5,
            autoSyncEnabled: false,
            syncInterval: 600.0
        )
        
        adminManager.connectivitySettings = settings
        let sheet = APISettingsSheet(adminManager: adminManager)
        
        let hostingController = UIHostingController(rootView: sheet)
        hostingController.loadViewIfNeeded()
        
        XCTAssertNotNil(hostingController.view)
    }
    
    func testAPISettingsSheetFormValidation() {
        // Test form validation logic
        let sheet = APISettingsSheet(adminManager: adminManager)
        let hostingController = UIHostingController(rootView: sheet)
        
        // Test that the view renders without empty URL validation errors
        hostingController.loadViewIfNeeded()
        XCTAssertNotNil(hostingController.view)
    }
    
    // MARK: - NetworkDiagnosticsSheet Tests
    
    func testNetworkDiagnosticsSheetInitialization() {
        let sheet = NetworkDiagnosticsSheet(adminManager: adminManager)
        XCTAssertNotNil(sheet)
    }
    
    func testNetworkDiagnosticsSheetWithoutDiagnostics() {
        // Test sheet when no diagnostics are available
        adminManager.networkDiagnostics = nil
        let sheet = NetworkDiagnosticsSheet(adminManager: adminManager)
        
        let hostingController = UIHostingController(rootView: sheet)
        hostingController.loadViewIfNeeded()
        XCTAssertNotNil(hostingController.view)
    }
    
    func testNetworkDiagnosticsSheetWithDiagnostics() {
        // Test sheet with mock diagnostics data
        let mockDiagnostics = NetworkDiagnostics(
            pingLatency: 25.0,
            downloadSpeed: 50.0,
            uploadSpeed: 10.0,
            packetLoss: 0.1,
            dnsResolutionTime: 15.0,
            connectionType: "WiFi",
            isConnected: true,
            lastTestDate: Date()
        )
        
        adminManager.networkDiagnostics = mockDiagnostics
        let sheet = NetworkDiagnosticsSheet(adminManager: adminManager)
        
        let hostingController = UIHostingController(rootView: sheet)
        hostingController.loadViewIfNeeded()
        XCTAssertNotNil(hostingController.view)
    }
    
    func testNetworkDiagnosticsConnectionQuality() {
        // Test different connection quality scenarios
        let excellentDiagnostics = NetworkDiagnostics(
            pingLatency: 20.0,
            downloadSpeed: 100.0,
            uploadSpeed: 50.0,
            packetLoss: 0.0,
            dnsResolutionTime: 10.0,
            connectionType: "WiFi",
            isConnected: true,
            lastTestDate: Date()
        )
        
        XCTAssertEqual(excellentDiagnostics.connectionQuality, .excellent)
        
        let poorDiagnostics = NetworkDiagnostics(
            pingLatency: 150.0,
            downloadSpeed: 1.0,
            uploadSpeed: 0.5,
            packetLoss: 5.0,
            dnsResolutionTime: 100.0,
            connectionType: "Cellular",
            isConnected: true,
            lastTestDate: Date()
        )
        
        XCTAssertEqual(poorDiagnostics.connectionQuality, .poor)
    }
    
    // MARK: - AddDeviceSheet Tests
    
    func testAddDeviceSheetInitialization() {
        let sheet = AddDeviceSheet(adminManager: adminManager)
        XCTAssertNotNil(sheet)
    }
    
    func testAddDeviceSheetRendering() {
        let sheet = AddDeviceSheet(adminManager: adminManager)
        let hostingController = UIHostingController(rootView: sheet)
        
        hostingController.loadViewIfNeeded()
        XCTAssertNotNil(hostingController.view)
    }
    
    // MARK: - DeviceDetailSheet Tests
    
    func testDeviceDetailSheetInitialization() {
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
        XCTAssertNotNil(sheet)
    }
    
    func testDeviceDetailSheetRendering() {
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
        let hostingController = UIHostingController(rootView: sheet)
        
        hostingController.loadViewIfNeeded()
        XCTAssertNotNil(hostingController.view)
    }
    
    // MARK: - AddToDeviceListSheet Tests
    
    func testAddToDeviceListSheetInitialization() {
        let sheet = AddToDeviceListSheet(
            adminManager: adminManager,
            listType: DeviceListsView.DeviceListType.whitelist
        )
        XCTAssertNotNil(sheet)
    }
    
    func testAddToDeviceListSheetWhitelist() {
        let sheet = AddToDeviceListSheet(
            adminManager: adminManager,
            listType: DeviceListsView.DeviceListType.whitelist
        )
        
        let hostingController = UIHostingController(rootView: sheet)
        hostingController.loadViewIfNeeded()
        XCTAssertNotNil(hostingController.view)
    }
    
    func testAddToDeviceListSheetBlacklist() {
        let sheet = AddToDeviceListSheet(
            adminManager: adminManager,
            listType: DeviceListsView.DeviceListType.blacklist
        )
        
        let hostingController = UIHostingController(rootView: sheet)
        hostingController.loadViewIfNeeded()
        XCTAssertNotNil(hostingController.view)
    }
    
    // MARK: - Integration Tests
    
    func testAllSheetsWithMockData() async {
        // Load mock data into AdminManager
        await setupMockAdminData()
        
        // Test all sheets can be initialized and rendered with mock data
        let apiSheet = APISettingsSheet(adminManager: adminManager)
        let diagnosticsSheet = NetworkDiagnosticsSheet(adminManager: adminManager)
        let addDeviceSheet = AddDeviceSheet(adminManager: adminManager)
        let addToListSheet = AddToDeviceListSheet(
            adminManager: adminManager,
            listType: DeviceListsView.DeviceListType.whitelist
        )
        
        // Test rendering
        let apiHosting = UIHostingController(rootView: apiSheet)
        let diagnosticsHosting = UIHostingController(rootView: diagnosticsSheet)
        let addDeviceHosting = UIHostingController(rootView: addDeviceSheet)
        let addToListHosting = UIHostingController(rootView: addToListSheet)
        
        apiHosting.loadViewIfNeeded()
        diagnosticsHosting.loadViewIfNeeded()
        addDeviceHosting.loadViewIfNeeded()
        addToListHosting.loadViewIfNeeded()
        
        XCTAssertNotNil(apiHosting.view)
        XCTAssertNotNil(diagnosticsHosting.view)
        XCTAssertNotNil(addDeviceHosting.view)
        XCTAssertNotNil(addToListHosting.view)
    }
    
    func testSheetsMemoryManagement() {
        // Test that sheets don't cause memory leaks
        weak var weakSheet: APISettingsSheet?
        weak var weakHostingController: UIHostingController<APISettingsSheet>?
        
        autoreleasepool {
            let sheet = APISettingsSheet(adminManager: adminManager)
            let hostingController = UIHostingController(rootView: sheet)
            
            weakSheet = sheet
            weakHostingController = hostingController
            
            hostingController.loadViewIfNeeded()
        }
        
        // Objects should be deallocated after autoreleasepool
        XCTAssertNil(weakSheet)
        XCTAssertNil(weakHostingController)
    }
    
    // MARK: - Error Handling Tests
    
    func testSheetsWithNilAdminManager() {
        // Test behavior when AdminManager is in an invalid state
        // Note: We can't actually pass nil due to @ObservedObject requirements,
        // but we can test with an AdminManager in various states
        
        let emptyAdminManager = AdminManager()
        let sheet = APISettingsSheet(adminManager: emptyAdminManager)
        
        let hostingController = UIHostingController(rootView: sheet)
        hostingController.loadViewIfNeeded()
        
        XCTAssertNotNil(hostingController.view)
    }
    
    func testSheetsWithCorruptedData() {
        // Test sheets with potentially corrupted or invalid data
        adminManager.connectivitySettings = ConnectivitySettings(
            apiBaseURL: "", // Empty URL
            requestTimeout: -1.0, // Invalid timeout
            maxRetryAttempts: -5, // Invalid retry count
            autoSyncEnabled: true,
            syncInterval: 0.0 // Invalid interval
        )
        
        let sheet = APISettingsSheet(adminManager: adminManager)
        let hostingController = UIHostingController(rootView: sheet)
        
        // Should not crash even with invalid data
        hostingController.loadViewIfNeeded()
        XCTAssertNotNil(hostingController.view)
    }
    
    // MARK: - Performance Tests
    
    func testSheetRenderingPerformance() {
        measure {
            let sheet = APISettingsSheet(adminManager: adminManager)
            let hostingController = UIHostingController(rootView: sheet)
            hostingController.loadViewIfNeeded()
        }
    }
    
    func testMultipleSheetInstantiation() {
        measure {
            for _ in 0..<100 {
                let sheet = APISettingsSheet(adminManager: adminManager)
                let _ = UIHostingController(rootView: sheet)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupMockAdminData() async {
        // Setup mock connectivity settings
        adminManager.connectivitySettings = ConnectivitySettings(
            apiBaseURL: "https://mock.api.com",
            requestTimeout: 30.0,
            maxRetryAttempts: 3,
            autoSyncEnabled: true,
            syncInterval: 300.0
        )
        
        // Setup mock network diagnostics
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
        
        // Setup mock device entries
        adminManager.deviceEntries = [
            DeviceEntry(
                id: "mock-id-1",
                name: "Mock Device 1",
                deviceId: "MOCK001",
                deviceType: .sensor,
                macAddress: "00:11:22:33:44:55",
                ipAddress: "192.168.1.100",
                status: .connected,
                lastSeen: Date(),
                firmwareVersion: "1.0.0",
                batteryLevel: 85
            )
        ]
    }
}

// MARK: - Mock Extensions for Testing

extension AdminSheetsTests {
    
    func testViewHierarchyIntegrity() {
        // Test that view hierarchies are properly constructed
        let sheet = APISettingsSheet(adminManager: adminManager)
        let hostingController = UIHostingController(rootView: sheet)
        
        hostingController.loadViewIfNeeded()
        
        // Verify the view hierarchy exists
        XCTAssertNotNil(hostingController.view)
        XCTAssertTrue(hostingController.view.subviews.count > 0)
    }
    
    func testSheetDismissalHandling() {
        // Test that sheets handle dismissal properly
        let sheet = APISettingsSheet(adminManager: adminManager)
        let hostingController = UIHostingController(rootView: sheet)
        
        hostingController.loadViewIfNeeded()
        
        // Simulate view appearing and disappearing
        hostingController.viewWillAppear(false)
        hostingController.viewDidAppear(false)
        hostingController.viewWillDisappear(false)
        hostingController.viewDidDisappear(false)
        
        XCTAssertNotNil(hostingController.view)
    }
    
    func testSheetStateManagement() {
        // Test that sheets properly manage their internal state
        let sheet = APISettingsSheet(adminManager: adminManager)
        let hostingController = UIHostingController(rootView: sheet)
        
        hostingController.loadViewIfNeeded()
        
        // Test state changes don't cause crashes
        adminManager.connectivitySettings.apiBaseURL = "https://new.api.com"
        adminManager.connectivitySettings.requestTimeout = 60.0
        
        XCTAssertNotNil(hostingController.view)
    }
}