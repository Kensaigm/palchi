import SwiftUI

// MARK: - API Settings Sheet
struct APISettingsSheet: View {
    @ObservedObject var adminManager: AdminManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var apiBaseURL: String = ""
    @State private var requestTimeout: Double = 30.0
    @State private var maxRetryAttempts: Int = 3
    @State private var autoSyncEnabled: Bool = true
    @State private var syncInterval: Double = 300.0
    
    var body: some View {
        NavigationView {
            Form {
                Section("API Configuration") {
                    HStack {
                        Text("Base URL")
                        TextField("https://api.example.com", text: $apiBaseURL)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack {
                        Text("Timeout")
                        Spacer()
                        Text("\(Int(requestTimeout))s")
                            .foregroundColor(.secondary)
                    }
                    Slider(value: $requestTimeout, in: 5...120, step: 5)
                    
                    Stepper("Retry Attempts: \(maxRetryAttempts)", value: $maxRetryAttempts, in: 1...10)
                }
                
                Section("Sync Settings") {
                    Toggle("Auto Sync", isOn: $autoSyncEnabled)
                    
                    if autoSyncEnabled {
                        HStack {
                            Text("Interval")
                            Spacer()
                            Text("\(Int(syncInterval / 60)) minutes")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $syncInterval, in: 60...3600, step: 60)
                    }
                }
                
                Section("Actions") {
                    Button("Test Connection") {
                        Task {
                            await adminManager.runNetworkDiagnostics()
                        }
                    }
                    .disabled(apiBaseURL.isEmpty)
                    
                    Button("Reset to Defaults") {
                        resetToDefaults()
                    }
                    .foregroundColor(.orange)
                }
            }
            .navigationTitle("API Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSettings()
                    }
                    .disabled(apiBaseURL.isEmpty)
                }
            }
        }
        .onAppear {
            loadCurrentSettings()
        }
    }
    
    private func loadCurrentSettings() {
        let settings = adminManager.connectivitySettings
        apiBaseURL = settings.apiBaseURL
        requestTimeout = settings.requestTimeout
        maxRetryAttempts = settings.maxRetryAttempts
        autoSyncEnabled = settings.autoSyncEnabled
        syncInterval = settings.syncInterval
    }
    
    private func saveSettings() {
        let settings = ConnectivitySettings(
            apiBaseURL: apiBaseURL,
            requestTimeout: requestTimeout,
            maxRetryAttempts: maxRetryAttempts,
            autoSyncEnabled: autoSyncEnabled,
            syncInterval: syncInterval
        )
        
        Task {
            await adminManager.updateConnectivitySettings(settings)
            dismiss()
        }
    }
    
    private func resetToDefaults() {
        apiBaseURL = "https://your-api-server.com/api"
        requestTimeout = 30.0
        maxRetryAttempts = 3
        autoSyncEnabled = true
        syncInterval = 300.0
    }
}

// MARK: - Network Diagnostics Sheet
struct NetworkDiagnosticsSheet: View {
    @ObservedObject var adminManager: AdminManager
    @Environment(\.dismiss) private var dismiss
    @State private var isRunningTest = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isRunningTest {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("Running Network Diagnostics...")
                            .font(.headline)
                        
                        Text("This may take a few moments")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let diagnostics = adminManager.networkDiagnostics {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Connection Quality
                            VStack(spacing: 8) {
                                Text("Connection Quality")
                                    .font(.headline)
                                
                                Text(diagnostics.connectionQuality.description)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(diagnostics.connectionQuality.color)
                            }
                            .padding()
                            .background(Color(.systemGroupedBackground))
                            .cornerRadius(12)
                            
                            // Detailed Results
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                DiagnosticCard(title: "Ping Latency", value: String(format: "%.0f ms", diagnostics.pingLatency))
                                DiagnosticCard(title: "Download Speed", value: String(format: "%.1f Mbps", diagnostics.downloadSpeed))
                                DiagnosticCard(title: "Upload Speed", value: String(format: "%.1f Mbps", diagnostics.uploadSpeed))
                                DiagnosticCard(title: "Packet Loss", value: String(format: "%.1f%%", diagnostics.packetLoss))
                                DiagnosticCard(title: "DNS Resolution", value: String(format: "%.0f ms", diagnostics.dnsResolutionTime))
                                DiagnosticCard(title: "Connection Type", value: diagnostics.connectionType)
                            }
                            
                            Button("Run Test Again") {
                                runDiagnostics()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "network")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        
                        Text("Network Diagnostics")
                            .font(.headline)
                        
                        Text("Test your network connection quality and performance")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Start Test") {
                            runDiagnostics()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Network Diagnostics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func runDiagnostics() {
        isRunningTest = true
        Task {
            await adminManager.runNetworkDiagnostics()
            isRunningTest = false
        }
    }
}

struct DiagnosticCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

// MARK: - Add Device Sheet
struct AddDeviceSheet: View {
    @ObservedObject var adminManager: AdminManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var deviceName: String = ""
    @State private var deviceId: String = ""
    @State private var deviceType: DeviceEntry.DeviceType = .palchiDevice
    @State private var macAddress: String = ""
    @State private var ipAddress: String = ""
    @State private var firmwareVersion: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Device Information") {
                    TextField("Device Name", text: $deviceName)
                    TextField("Device ID", text: $deviceId)
                    
                    Picker("Device Type", selection: $deviceType) {
                        ForEach(DeviceEntry.DeviceType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundColor(type.color)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                }
                
                Section("Network Information") {
                    TextField("MAC Address", text: $macAddress)
                        .textCase(.uppercase)
                    TextField("IP Address (Optional)", text: $ipAddress)
                }
                
                Section("Additional Information") {
                    TextField("Firmware Version (Optional)", text: $firmwareVersion)
                }
                
                Section("Actions") {
                    Button("Scan for Devices") {
                        // TODO: Implement device scanning
                    }
                    .disabled(true)
                }
            }
            .navigationTitle("Add Device")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addDevice()
                    }
                    .disabled(deviceName.isEmpty || deviceId.isEmpty || macAddress.isEmpty)
                }
            }
        }
    }
    
    private func addDevice() {
        let device = DeviceEntry(
            id: UUID().uuidString,
            name: deviceName,
            deviceId: deviceId,
            deviceType: deviceType,
            macAddress: macAddress,
            ipAddress: ipAddress.isEmpty ? nil : ipAddress,
            status: .disconnected,
            lastSeen: Date(),
            firmwareVersion: firmwareVersion.isEmpty ? nil : firmwareVersion,
            batteryLevel: nil
        )
        
        Task {
            await adminManager.addDevice(device)
            dismiss()
        }
    }
}

// MARK: - Device Detail Sheet
struct DeviceDetailSheet: View {
    let device: DeviceEntry
    @ObservedObject var adminManager: AdminManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var deviceName: String
    @State private var macAddress: String
    @State private var ipAddress: String
    @State private var firmwareVersion: String
    @State private var showingDeleteAlert = false
    
    init(device: DeviceEntry, adminManager: AdminManager) {
        self.device = device
        self.adminManager = adminManager
        self._deviceName = State(initialValue: device.name)
        self._macAddress = State(initialValue: device.macAddress)
        self._ipAddress = State(initialValue: device.ipAddress ?? "")
        self._firmwareVersion = State(initialValue: device.firmwareVersion ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Device Status") {
                    HStack {
                        Image(systemName: device.deviceType.icon)
                            .foregroundColor(device.deviceType.color)
                            .font(.title2)
                        
                        VStack(alignment: .leading) {
                            Text(device.deviceType.rawValue)
                                .font(.headline)
                            Text(device.deviceId)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            HStack {
                                Image(systemName: device.status.icon)
                                    .foregroundColor(device.status.color)
                                Text(device.status.rawValue)
                                    .foregroundColor(device.status.color)
                            }
                            .font(.caption)
                            
                            Text(device.lastSeen, style: .relative)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Device Information") {
                    TextField("Device Name", text: $deviceName)
                    TextField("MAC Address", text: $macAddress)
                        .textCase(.uppercase)
                    TextField("IP Address", text: $ipAddress)
                    TextField("Firmware Version", text: $firmwareVersion)
                }
                
                if let batteryLevel = device.batteryLevel {
                    Section("Battery") {
                        HStack {
                            Image(systemName: "battery.25")
                                .foregroundColor(batteryLevel < 20 ? .red : .green)
                            Text("Battery Level")
                            Spacer()
                            Text("\(batteryLevel)%")
                                .fontWeight(.medium)
                        }
                    }
                }
                
                Section("Actions") {
                    Button("Ping Device") {
                        // TODO: Implement ping
                    }
                    .disabled(device.status != .connected)
                    
                    Button("Update Firmware") {
                        // TODO: Implement firmware update
                    }
                    .disabled(device.status != .connected)
                    
                    Button("Delete Device") {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Device Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
            .alert("Delete Device", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteDevice()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this device? This action cannot be undone.")
            }
        }
    }
    
    private func saveChanges() {
        var updatedDevice = device
        updatedDevice.name = deviceName
        updatedDevice.macAddress = macAddress
        updatedDevice.ipAddress = ipAddress.isEmpty ? nil : ipAddress
        updatedDevice.firmwareVersion = firmwareVersion.isEmpty ? nil : firmwareVersion
        
        Task {
            await adminManager.updateDevice(updatedDevice)
            dismiss()
        }
    }
    
    private func deleteDevice() {
        Task {
            await adminManager.deleteDevice(device.id)
            dismiss()
        }
    }
}

// MARK: - Add to Device List Sheet
struct AddToDeviceListSheet: View {
    @ObservedObject var adminManager: AdminManager
    let listType: DeviceListsView.DeviceListType
    @Environment(\.dismiss) private var dismiss
    
    @State private var deviceId: String = ""
    @State private var deviceName: String = ""
    @State private var macAddress: String = ""
    @State private var notes: String = ""
    @State private var selectedExistingDevice: DeviceEntry?
    @State private var useExistingDevice = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Add to \(listType.rawValue)") {
                    Toggle("Use Existing Device", isOn: $useExistingDevice)
                }
                
                if useExistingDevice {
                    Section("Select Device") {
                        Picker("Device", selection: $selectedExistingDevice) {
                            Text("Select a device...").tag(nil as DeviceEntry?)
                            ForEach(adminManager.deviceEntries) { device in
                                HStack {
                                    Image(systemName: device.deviceType.icon)
                                        .foregroundColor(device.deviceType.color)
                                    Text(device.name)
                                }
                                .tag(device as DeviceEntry?)
                            }
                        }
                    }
                } else {
                    Section("Device Information") {
                        TextField("Device ID", text: $deviceId)
                        TextField("Device Name", text: $deviceName)
                        TextField("MAC Address", text: $macAddress)
                            .textCase(.uppercase)
                    }
                }
                
                Section("Additional Information") {
                    TextField("Notes (Optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add to \(listType.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addToList()
                    }
                    .disabled(!canAdd)
                }
            }
        }
    }
    
    private var canAdd: Bool {
        if useExistingDevice {
            return selectedExistingDevice != nil
        } else {
            return !deviceId.isEmpty && !deviceName.isEmpty && !macAddress.isEmpty
        }
    }
    
    private func addToList() {
        let entry: DeviceListEntry
        
        if let existingDevice = selectedExistingDevice {
            entry = DeviceListEntry(
                deviceId: existingDevice.deviceId,
                deviceName: existingDevice.name,
                macAddress: existingDevice.macAddress,
                addedBy: "admin",
                notes: notes.isEmpty ? nil : notes
            )
        } else {
            entry = DeviceListEntry(
                deviceId: deviceId,
                deviceName: deviceName,
                macAddress: macAddress,
                addedBy: "admin",
                notes: notes.isEmpty ? nil : notes
            )
        }
        
        Task {
            switch listType {
            case .whitelist:
                await adminManager.addToWhitelist(entry)
            case .blacklist:
                await adminManager.addToBlacklist(entry)
            }
            dismiss()
        }
    }
}