import XCTest
import SwiftUI
@testable import PalChiApp

/// Test configuration and utilities for AdminSheets testing
/// This class provides common setup and diagnostic utilities for AdminSheets tests
class AdminSheetsTestConfiguration: NSObject {
    
    static let shared = AdminSheetsTestConfiguration()
    
    private override init() {
        super.init()
    }
    
    // MARK: - Test Environment Setup
    
    /// Sets up the test environment for AdminSheets testing
    func setupTestEnvironment() {
        // Configure test-specific settings
        UserDefaults.standard.set(true, forKey: "isRunningTests")
        
        // Disable animations for faster testing
        UIView.setAnimationsEnabled(false)
        
        // Set up mock data if needed
        setupMockEnvironment()
    }
    
    /// Tears down the test environment
    func tearDownTestEnvironment() {
        UserDefaults.standard.removeObject(forKey: "isRunningTests")
        UIView.setAnimationsEnabled(true)
    }
    
    // MARK: - Mock Environment Setup
    
    private func setupMockEnvironment() {
        // Set up any global mock configurations
        // This can include network mocking, Core Data in-memory stores, etc.
    }
    
    // MARK: - Build Issue Diagnostics
    
    /// Runs diagnostic checks to identify potential build issues
    func runBuildDiagnostics() -> [String] {
        var issues: [String] = []
        
        // Check for common SwiftUI build issues
        issues.append(contentsOf: checkSwiftUIIssues())
        
        // Check for Core Data issues
        issues.append(contentsOf: checkCoreDataIssues())
        
        // Check for dependency issues
        issues.append(contentsOf: checkDependencyIssues())
        
        return issues
    }
    
    private func checkSwiftUIIssues() -> [String] {
        var issues: [String] = []
        
        // Check if SwiftUI framework is available
        if #available(iOS 13.0, *) {
            // SwiftUI is available
        } else {
            issues.append("SwiftUI requires iOS 13.0 or later")
        }
        
        return issues
    }
    
    private func checkCoreDataIssues() -> [String] {
        var issues: [String] = []
        
        // Check if Core Data model exists
        guard let modelURL = Bundle.main.url(forResource: "PalChiDataModel", withExtension: "momd") else {
            issues.append("Core Data model 'PalChiDataModel.momd' not found in main bundle")
            return issues
        }
        
        // Check if model can be loaded
        guard let _ = NSManagedObjectModel(contentsOf: modelURL) else {
            issues.append("Failed to load Core Data model from: \(modelURL)")
            return issues
        }
        
        return issues
    }
    
    private func checkDependencyIssues() -> [String] {
        var issues: [String] = []
        
        // Check for required classes
        let requiredClasses = [
            "AdminManager",
            "ConnectivitySettings",
            "NetworkDiagnostics",
            "DeviceEntry"
        ]
        
        for className in requiredClasses {
            if NSClassFromString("PalChiApp.\(className)") == nil {
                issues.append("Required class '\(className)' not found")
            }
        }
        
        return issues
    }
    
    // MARK: - Test Utilities
    
    /// Creates a test-safe AdminManager instance
    func createTestAdminManager() -> AdminManager? {
        do {
            return AdminManager()
        } catch {
            print("Failed to create AdminManager for testing: \(error)")
            return nil
        }
    }
    
    /// Validates that a SwiftUI view can be rendered without crashing
    func validateViewRendering<T: View>(_ view: T) -> Bool {
        do {
            let hostingController = UIHostingController(rootView: view)
            hostingController.loadViewIfNeeded()
            return hostingController.view != nil
        } catch {
            print("View rendering failed: \(error)")
            return false
        }
    }
    
    /// Checks for memory leaks in view controllers
    func checkForMemoryLeaks<T: View>(_ viewBuilder: () -> T) -> Bool {
        weak var weakController: UIHostingController<T>?
        
        autoreleasepool {
            let view = viewBuilder()
            let controller = UIHostingController(rootView: view)
            weakController = controller
            controller.loadViewIfNeeded()
        }
        
        // If weakController is nil, no memory leak
        return weakController == nil
    }
}

// MARK: - Test Base Class

/// Base class for AdminSheets tests with common setup and utilities
class AdminSheetsTestBase: XCTestCase {
    
    var testConfig: AdminSheetsTestConfiguration!
    var adminManager: AdminManager!
    
    override func setUp() {
        super.setUp()
        
        testConfig = AdminSheetsTestConfiguration.shared
        testConfig.setupTestEnvironment()
        
        adminManager = testConfig.createTestAdminManager()
        
        // Run build diagnostics
        let issues = testConfig.runBuildDiagnostics()
        if !issues.isEmpty {
            print("⚠️ Build diagnostics found issues:")
            for issue in issues {
                print("  - \(issue)")
            }
        }
    }
    
    override func tearDown() {
        adminManager = nil
        testConfig.tearDownTestEnvironment()
        testConfig = nil
        
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    func validateSheetRendering<T: View>(_ sheet: T) {
        XCTAssertTrue(testConfig.validateViewRendering(sheet), "Sheet failed to render properly")
    }
    
    func checkSheetMemoryLeak<T: View>(_ sheetBuilder: @escaping () -> T) {
        XCTAssertTrue(testConfig.checkForMemoryLeaks(sheetBuilder), "Memory leak detected in sheet")
    }
}

// MARK: - Specific Test Diagnostics

extension AdminSheetsTestConfiguration {
    
    /// Specific diagnostics for AdminSheets components
    func runAdminSheetsSpecificDiagnostics() -> [String] {
        var issues: [String] = []
        
        // Test AdminManager availability
        if createTestAdminManager() == nil {
            issues.append("AdminManager cannot be instantiated")
        }
        
        // Test model availability
        issues.append(contentsOf: checkModelAvailability())
        
        // Test view compilation
        issues.append(contentsOf: checkViewCompilation())
        
        return issues
    }
    
    private func checkModelAvailability() -> [String] {
        var issues: [String] = []
        
        // Check if we can create model instances
        let testSettings = ConnectivitySettings()
        if testSettings.apiBaseURL.isEmpty {
            // This is expected for default settings
        }
        
        return issues
    }
    
    private func checkViewCompilation() -> [String] {
        var issues: [String] = []
        
        // Try to compile basic SwiftUI views
        do {
            let testView = Text("Test")
            let _ = UIHostingController(rootView: testView)
        } catch {
            issues.append("Basic SwiftUI view compilation failed: \(error)")
        }
        
        return issues
    }
}