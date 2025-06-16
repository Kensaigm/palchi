import SwiftUI
import CoreLocation

struct AdminView: View {
    @StateObject private var adminManager = AdminManager()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // Statistics Tab
                DatabaseStatisticsView(adminManager: adminManager)
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Statistics")
                    }
                    .tag(0)
                
                // Connectivity Tab
                ConnectivitySettingsView(adminManager: adminManager)
                    .tabItem {
                        Image(systemName: "wifi.circle.fill")
                        Text("Connectivity")
                    }
                    .tag(1)
                
                // Device Management Tab
                DeviceManagementView(adminManager: adminManager)
                    .tabItem {
                        Image(systemName: "externaldrive.fill")
                        Text("Devices")
                    }
                    .tag(2)
                
                // Location Services Tab
                LocationServicesView(adminManager: adminManager)
                    .tabItem {
                        Image(systemName: "location.fill")
                        Text("Location")
                    }
                    .tag(3)
                
                // Device Lists Tab
                DeviceListsView(adminManager: adminManager)
                    .tabItem {
                        Image(systemName: "list.bullet.circle.fill")
                        Text("Lists")
                    }
                    .tag(4)
            }
            .navigationTitle("Admin Panel")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        Task {
                            await adminManager.refreshAllData()
                        }
                    }
                    .disabled(adminManager.isLoading)
                }
            }
        }
        .task {
            await adminManager.loadInitialData()
        }
    }
}

// MARK: - Database Statistics View
struct DatabaseStatisticsView: View {
    @ObservedObject var adminManager: AdminManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Database Overview
                AdminSectionCard(title: "Database Overview", icon: "cylinder.fill") {
                    if let stats = adminManager.databaseStats {
                        DatabaseOverviewContent(stats: stats)
                    } else {
                        LoadingView(message: "Loading database statistics...")
                    }
                }
                
                // Session Statistics
                AdminSectionCard(title: "Session Statistics", icon: "chart.line.uptrend.xyaxis") {
                    if let sessionStats = adminManager.sessionStatistics {
                        SessionStatisticsContent(stats: sessionStats)
                    } else {
                        LoadingView(message: "Loading session statistics...")
                    }
                }
                
                // Storage Analysis
                AdminSectionCard(title: "Storage Analysis", icon: "internaldrive") {
                    if let storageStats = adminManager.storageStats {
                        StorageAnalysisContent(stats: storageStats)
                    } else {
                        LoadingView(message: "Loading storage analysis...")
                    }
                }
                
                // Performance Metrics
                AdminSectionCard(title: "Performance Metrics", icon: "speedometer") {
                    if let perfStats = adminManager.performanceStats {
                        PerformanceMetricsContent(stats: perfStats)
                    } else {
                        LoadingView(message: "Loading performance metrics...")
                    }
                }
            }
            .padding()
        }
        .refreshable {
            await adminManager.refreshDatabaseStats()
        }
    }
}

// MARK: - Connectivity Settings View
struct ConnectivitySettingsView: View {
    @ObservedObject var adminManager: AdminManager
    @State private var showingAPISettings = false
    @State private var showingNetworkDiagnostics = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // API Configuration
                AdminSectionCard(title: "API Configuration", icon: "server.rack") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Base URL:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(adminManager.connectivitySettings.apiBaseURL)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        HStack {
                            Text("Timeout:")
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(Int(adminManager.connectivitySettings.requestTimeout))s")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Retry Attempts:")
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(adminManager.connectivitySettings.maxRetryAttempts)")
                                .foregroundColor(.secondary)
                        }
                        
                        Button("Configure API Settings") {
                            showingAPISettings = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                // Network Status
                AdminSectionCard(title: "Network Status", icon: "network") {
                    NetworkStatusContent(adminManager: adminManager)
                }
                
                // Sync Settings
                AdminSectionCard(title: "Sync Settings", icon: "arrow.clockwise.circle") {
                    SyncSettingsContent(adminManager: adminManager)
                }
                
                // Network Diagnostics
                AdminSectionCard(title: "Network Diagnostics", icon: "stethoscope") {
                    VStack(spacing: 12) {
                        Button("Run Network Diagnostics") {
                            showingNetworkDiagnostics = true
                        }
                        .buttonStyle(.bordered)
                        
                        if let diagnostics = adminManager.networkDiagnostics {
                            NetworkDiagnosticsContent(diagnostics: diagnostics)
                        }
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingAPISettings) {
            APISettingsSheet(adminManager: adminManager)
        }
        .sheet(isPresented: $showingNetworkDiagnostics) {
            NetworkDiagnosticsSheet(adminManager: adminManager)
        }
    }
}

// MARK: - Device Management View
struct DeviceManagementView: View {
    @ObservedObject var adminManager: AdminManager
    @State private var showingAddDevice = false
    @State private var selectedDevice: DeviceEntry?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Add Button
            HStack {
                Text("Registered Devices")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    showingAddDevice = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            
            // Device List
            if adminManager.deviceEntries.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "externaldrive.badge.questionmark")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    
                    Text("No devices registered")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Add devices to manage connections and permissions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Add First Device") {
                        showingAddDevice = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                List {
                    ForEach(adminManager.deviceEntries) { device in
                        DeviceEntryRow(device: device) {
                            selectedDevice = device
                        }
                    }
                    .onDelete(perform: deleteDevices)
                }
            }
        }
        .sheet(isPresented: $showingAddDevice) {
            AddDeviceSheet(adminManager: adminManager)
        }
        .sheet(item: $selectedDevice) { device in
            DeviceDetailSheet(device: device, adminManager: adminManager)
        }
    }
    
    private func deleteDevices(offsets: IndexSet) {
        Task {
            for index in offsets {
                let device = adminManager.deviceEntries[index]
                await adminManager.deleteDevice(device.id)
            }
        }
    }
}

// MARK: - Location Services View
struct LocationServicesView: View {
    @ObservedObject var adminManager: AdminManager
    @State private var showingLocationPermissionAlert = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Location Services Status
                AdminSectionCard(title: "Location Services", icon: "location.circle") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Status:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(adminManager.locationSettings.authorizationStatus.description)
                                .foregroundColor(adminManager.locationSettings.authorizationStatus.color)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Accuracy:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(adminManager.locationSettings.desiredAccuracy.description)
                                .foregroundColor(.secondary)
                        }
                        
                        Toggle("Enable Location Services", isOn: Binding(
                            get: { adminManager.locationSettings.isEnabled },
                            set: { newValue in
                                Task {
                                    await adminManager.toggleLocationServices(newValue)
                                }
                            }
                        ))
                        .disabled(adminManager.locationSettings.authorizationStatus == .denied)
                        
                        if adminManager.locationSettings.authorizationStatus == .denied {
                            Button("Open Settings") {
                                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(settingsUrl)
                                }
                            }
                            .buttonStyle(.bordered)
                        } else if adminManager.locationSettings.authorizationStatus == .notDetermined {
                            Button("Request Permission") {
                                Task {
                                    await adminManager.requestLocationPermission()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
                
                // Location Settings
                AdminSectionCard(title: "Location Settings", icon: "gear") {
                    LocationSettingsContent(adminManager: adminManager)
                }
                
                // Current Location
                AdminSectionCard(title: "Current Location", icon: "location.fill") {
                    CurrentLocationContent(adminManager: adminManager)
                }
                
                // Location History
                AdminSectionCard(title: "Location History", icon: "clock.arrow.circlepath") {
                    LocationHistoryContent(adminManager: adminManager)
                }
            }
            .padding()
        }
    }
}

// MARK: - Device Lists View
struct DeviceListsView: View {
    @ObservedObject var adminManager: AdminManager
    @State private var selectedList: DeviceListType = .whitelist
    @State private var showingAddToList = false
    
    enum DeviceListType: String, CaseIterable {
        case whitelist = "Whitelist"
        case blacklist = "Blacklist"
        
        var icon: String {
            switch self {
            case .whitelist: return "checkmark.shield.fill"
            case .blacklist: return "xmark.shield.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .whitelist: return .green
            case .blacklist: return .red
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Segmented Control
            Picker("Device List", selection: $selectedList) {
                ForEach(DeviceListType.allCases, id: \.self) { listType in
                    Text(listType.rawValue).tag(listType)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(Color(.systemGroupedBackground))
            
            // List Content
            VStack(spacing: 0) {
                // Header
                HStack {
                    Image(systemName: selectedList.icon)
                        .foregroundColor(selectedList.color)
                    
                    Text("\(selectedList.rawValue) (\(currentListCount))")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: {
                        showingAddToList = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // Device List
                if currentList.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: selectedList.icon)
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        
                        Text("No devices in \(selectedList.rawValue.lowercased())")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Add devices to control access permissions")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Add Device") {
                            showingAddToList = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    List {
                        ForEach(currentList) { device in
                            DeviceListRow(device: device, listType: selectedList)
                        }
                        .onDelete(perform: deleteFromList)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddToList) {
            AddToDeviceListSheet(
                adminManager: adminManager,
                listType: selectedList
            )
        }
    }
    
    private var currentList: [DeviceListEntry] {
        switch selectedList {
        case .whitelist:
            return adminManager.whitelistedDevices
        case .blacklist:
            return adminManager.blacklistedDevices
        }
    }
    
    private var currentListCount: Int {
        currentList.count
    }
    
    private func deleteFromList(offsets: IndexSet) {
        Task {
            for index in offsets {
                let device = currentList[index]
                switch selectedList {
                case .whitelist:
                    await adminManager.removeFromWhitelist(device.deviceId)
                case .blacklist:
                    await adminManager.removeFromBlacklist(device.deviceId)
                }
            }
        }
    }
}

#Preview {
    AdminView()
}