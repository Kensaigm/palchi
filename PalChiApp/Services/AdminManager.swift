import Foundation
import SwiftUI
import CoreLocation

@MainActor
class AdminManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var databaseStats: DatabaseStats?
    @Published var sessionStatistics: SessionStatistics?
    @Published var storageStats: StorageStats?
    @Published var performanceStats: PerformanceStats?
    @Published var connectivitySettings = ConnectivitySettings()
    @Published var networkDiagnostics: NetworkDiagnostics?
    @Published var deviceEntries: [DeviceEntry] = []
    @Published var locationSettings = LocationSettings()
    @Published var whitelistedDevices: [DeviceListEntry] = []
    @Published var blacklistedDevices: [DeviceListEntry] = []
    
    // MARK: - Private Properties
    private let sessionManager: SessionManager
    private let locationManager = CLLocationManager()
    
    init() {
        self.sessionManager = SessionManager(apiBaseURL: "https://your-api-server.com/api")
        setupLocationManager()
    }
    
    // MARK: - Initial Data Loading
    func loadInitialData() async {
        isLoading = true
        
        async let databaseTask = refreshDatabaseStats()
        async let connectivityTask = loadConnectivitySettings()
        async let devicesTask = loadDeviceEntries()
        async let locationTask = loadLocationSettings()
        async let listsTask = loadDeviceLists()
        
        await databaseTask
        await connectivityTask
        await devicesTask
        await locationTask
        await listsTask
        
        isLoading = false
    }
    
    func refreshAllData() async {
        await loadInitialData()
    }
    
    // MARK: - Database Statistics
    func refreshDatabaseStats() async {
        do {
            // Get basic storage stats
            let basicStats = try await sessionManager.getStorageStats()
            storageStats = basicStats
            
            // Generate detailed database statistics
            databaseStats = await generateDatabaseStats()
            sessionStatistics = await generateSessionStatistics()
            performanceStats = await generatePerformanceStats()
            
        } catch {
            print("Error refreshing database stats: \(error)")
        }
    }
    
    private func generateDatabaseStats() async -> DatabaseStats {
        // Mock implementation - in real app, query actual database
        return DatabaseStats(
            totalTables: 5,
            totalRecords: Int.random(in: 1000...10000),
            databaseSize: Int64.random(in: 1024*1024...100*1024*1024), // 1MB to 100MB
            lastVacuum: Date().addingTimeInterval(-Double.random(in: 0...86400*7)),
            indexCount: 12,
            averageQueryTime: Double.random(in: 0.001...0.1),
            connectionCount: Int.random(in: 1...5)
        )
    }
    
    private func generateSessionStatistics() async -> SessionStatistics {
        return SessionStatistics(
            totalSessions: Int.random(in: 100...1000),
            sessionsToday: Int.random(in: 0...50),
            sessionsThisWeek: Int.random(in: 10...200),
            sessionsThisMonth: Int.random(in: 50...800),
            averageSessionDuration: Double.random(in: 300...3600),
            mostActiveHour: Int.random(in: 0...23),
            syncSuccessRate: Double.random(in: 0.8...1.0),
            errorRate: Double.random(in: 0.0...0.1)
        )
    }
    
    private func generatePerformanceStats() async -> PerformanceStats {
        return PerformanceStats(
            averageResponseTime: Double.random(in: 0.1...2.0),
            memoryUsage: Double.random(in: 50...200), // MB
            cpuUsage: Double.random(in: 5...50), // Percentage
            diskIORate: Double.random(in: 1...100), // MB/s
            networkLatency: Double.random(in: 10...500), // ms
            cacheHitRate: Double.random(in: 0.7...0.95),
            uptime: TimeInterval.random(in: 3600...86400*30) // 1 hour to 30 days
        )
    }
    
    // MARK: - Connectivity Settings
    func loadConnectivitySettings() async {
        // Load from UserDefaults or configuration
        connectivitySettings = ConnectivitySettings(
            apiBaseURL: UserDefaults.standard.string(forKey: "api_base_url") ?? "https://your-api-server.com/api",
            requestTimeout: UserDefaults.standard.double(forKey: "request_timeout") != 0 ? 
                UserDefaults.standard.double(forKey: "request_timeout") : 30.0,
            maxRetryAttempts: UserDefaults.standard.integer(forKey: "max_retry_attempts") != 0 ?
                UserDefaults.standard.integer(forKey: "max_retry_attempts") : 3,
            autoSyncEnabled: UserDefaults.standard.bool(forKey: "auto_sync_enabled"),
            syncInterval: UserDefaults.standard.double(forKey: "sync_interval") != 0 ?
                UserDefaults.standard.double(forKey: "sync_interval") : 300.0
        )
    }
    
    func updateConnectivitySettings(_ settings: ConnectivitySettings) async {
        connectivitySettings = settings
        
        // Save to UserDefaults
        UserDefaults.standard.set(settings.apiBaseURL, forKey: "api_base_url")
        UserDefaults.standard.set(settings.requestTimeout, forKey: "request_timeout")
        UserDefaults.standard.set(settings.maxRetryAttempts, forKey: "max_retry_attempts")
        UserDefaults.standard.set(settings.autoSyncEnabled, forKey: "auto_sync_enabled")
        UserDefaults.standard.set(settings.syncInterval, forKey: "sync_interval")
    }
    
    func runNetworkDiagnostics() async {
        isLoading = true
        
        // Simulate network diagnostics
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        networkDiagnostics = NetworkDiagnostics(
            pingLatency: Double.random(in: 10...200),
            downloadSpeed: Double.random(in: 1...100), // Mbps
            uploadSpeed: Double.random(in: 0.5...50), // Mbps
            packetLoss: Double.random(in: 0...5), // Percentage
            dnsResolutionTime: Double.random(in: 5...100), // ms
            connectionType: ["WiFi", "Cellular", "Ethernet"].randomElement() ?? "WiFi",
            isConnected: Bool.random(),
            lastTestDate: Date()
        )
        
        isLoading = false
    }
    
    // MARK: - Device Management
    func loadDeviceEntries() async {
        // Mock device entries - in real app, load from database
        deviceEntries = [
            DeviceEntry(
                id: UUID().uuidString,
                name: "PalChi Device #1",
                deviceId: "PALCHI_001",
                deviceType: .palchiDevice,
                macAddress: "00:1B:44:11:3A:B7",
                ipAddress: "192.168.1.100",
                status: .connected,
                lastSeen: Date(),
                firmwareVersion: "1.2.3",
                batteryLevel: 85
            ),
            DeviceEntry(
                id: UUID().uuidString,
                name: "Backup Sensor",
                deviceId: "SENSOR_002",
                deviceType: .sensor,
                macAddress: "00:1B:44:11:3A:B8",
                ipAddress: "192.168.1.101",
                status: .disconnected,
                lastSeen: Date().addingTimeInterval(-3600),
                firmwareVersion: "2.1.0",
                batteryLevel: 42
            )
        ]
    }
    
    func addDevice(_ device: DeviceEntry) async {
        deviceEntries.append(device)
        // In real app, save to database
    }
    
    func deleteDevice(_ deviceId: String) async {
        deviceEntries.removeAll { $0.id == deviceId }
        // In real app, delete from database
    }
    
    func updateDevice(_ device: DeviceEntry) async {
        if let index = deviceEntries.firstIndex(where: { $0.id == device.id }) {
            deviceEntries[index] = device
            // In real app, update in database
        }
    }
    
    // MARK: - Location Services
    private func setupLocationManager() {
        locationManager.delegate = LocationManagerDelegate(adminManager: self)
        updateLocationSettings()
    }
    
    func loadLocationSettings() async {
        updateLocationSettings()
    }
    
    private func updateLocationSettings() {
        locationSettings = LocationSettings(
            isEnabled: UserDefaults.standard.bool(forKey: "location_enabled"),
            authorizationStatus: CLLocationManager.authorizationStatus(),
            desiredAccuracy: kCLLocationAccuracyBest,
            currentLocation: nil // Will be updated by location manager
        )
    }
    
    func toggleLocationServices(_ enabled: Bool) async {
        UserDefaults.standard.set(enabled, forKey: "location_enabled")
        locationSettings.isEnabled = enabled
        
        if enabled && locationSettings.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func requestLocationPermission() async {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func updateCurrentLocation(_ location: CLLocation) {
        locationSettings.currentLocation = location
    }
    
    // MARK: - Device Lists (Whitelist/Blacklist)
    func loadDeviceLists() async {
        // Mock data - in real app, load from database
        whitelistedDevices = [
            DeviceListEntry(
                id: UUID().uuidString,
                deviceId: "PALCHI_001",
                deviceName: "PalChi Device #1",
                macAddress: "00:1B:44:11:3A:B7",
                dateAdded: Date().addingTimeInterval(-86400),
                addedBy: "admin"
            )
        ]
        
        blacklistedDevices = [
            DeviceListEntry(
                id: UUID().uuidString,
                deviceId: "UNKNOWN_999",
                deviceName: "Unknown Device",
                macAddress: "00:1B:44:11:3A:FF",
                dateAdded: Date().addingTimeInterval(-3600),
                addedBy: "admin"
            )
        ]
    }
    
    func addToWhitelist(_ entry: DeviceListEntry) async {
        whitelistedDevices.append(entry)
        // Remove from blacklist if present
        blacklistedDevices.removeAll { $0.deviceId == entry.deviceId }
        // In real app, save to database
    }
    
    func addToBlacklist(_ entry: DeviceListEntry) async {
        blacklistedDevices.append(entry)
        // Remove from whitelist if present
        whitelistedDevices.removeAll { $0.deviceId == entry.deviceId }
        // In real app, save to database
    }
    
    func removeFromWhitelist(_ deviceId: String) async {
        whitelistedDevices.removeAll { $0.deviceId == deviceId }
        // In real app, delete from database
    }
    
    func removeFromBlacklist(_ deviceId: String) async {
        blacklistedDevices.removeAll { $0.deviceId == deviceId }
        // In real app, delete from database
    }
}

// MARK: - Location Manager Delegate
class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    weak var adminManager: AdminManager?
    
    init(adminManager: AdminManager) {
        self.adminManager = adminManager
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            adminManager?.updateCurrentLocation(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            adminManager?.updateLocationSettings()
        }
    }
}