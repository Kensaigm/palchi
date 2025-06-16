import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var palchiApp = PALCHIApp()
    @State private var selectedSession: SessionData?

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                // Quick Actions Bar
                QuickActionsPanel(palchiApp: palchiApp)
                    .frame(height: 80)

                // Top Row: Active Communications (left) and Map (right)
                HStack(spacing: 16) {
                    // Active Communications Panel - Top Left
                    ActiveCommunicationsPanel()
                        .frame(width: geometry.size.width * 0.48, height: geometry.size.height * 0.35)

                    // Map Panel - Top Right
                    MapPanel(selectedSession: selectedSession, sessions: palchiApp.recentSessions)
                        .frame(width: geometry.size.width * 0.48, height: geometry.size.height * 0.35)
                }

                // Bottom Row: Session Summary Panel
                SessionSummaryPanel(
                    sessions: palchiApp.recentSessions,
                    storageStats: palchiApp.storageStats,
                    selectedSession: $selectedSession,
                    onSessionSelected: { session in
                        selectedSession = session
                    }
                )
                .frame(height: geometry.size.height * 0.35)
            }
            .padding()
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle("PalChi Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await loadDashboardData()
        }
        .refreshable {
            await loadDashboardData()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                AdminMenuButton()
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Sync") {
                    Task {
                        await palchiApp.forceSync()
                    }
                }
                .disabled(palchiApp.isLoading)
            }
        }
    }

    private func loadDashboardData() async {
        await palchiApp.checkStorageStatus()
        await palchiApp.loadRecentSessions()
    }
}

// MARK: - Active Communications Panel
struct ActiveCommunicationsPanel: View {
    @State private var deviceConnections: [DeviceConnection] = []
    @State private var isScanning = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundColor(.blue)
                Text("Active Communications")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: {
                    Task {
                        await scanForDevices()
                    }
                }) {
                    Image(systemName: isScanning ? "arrow.clockwise" : "arrow.clockwise.circle")
                        .foregroundColor(.blue)
                        .rotationEffect(.degrees(isScanning ? 360 : 0))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isScanning)
                }
            }

            Divider()

            if deviceConnections.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "wifi.slash")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("No devices connected")
                        .foregroundColor(.secondary)
                    Text("Tap refresh to scan for devices")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(deviceConnections) { connection in
                            DeviceConnectionRow(connection: connection)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .task {
            await loadDeviceConnections()
        }
    }

    private func loadDeviceConnections() async {
        // Mock device connections
        deviceConnections = [
            DeviceConnection(
                id: "device_001",
                name: "PalChi Device #1",
                type: .palchiDevice,
                status: .connected,
                signalStrength: 85,
                lastSeen: Date()
            ),
            DeviceConnection(
                id: "device_002",
                name: "Backup Sensor",
                type: .sensor,
                status: .connecting,
                signalStrength: 62,
                lastSeen: Date().addingTimeInterval(-300)
            )
        ]
    }

    private func scanForDevices() async {
        isScanning = true
        // Simulate scanning delay
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        await loadDeviceConnections()
        isScanning = false
    }
}

// MARK: - Admin Menu Button
struct AdminMenuButton: View {
    @State private var showingAdminView = false

    var body: some View {
        Button(action: {
            showingAdminView = true
        }) {
            Image(systemName: "gearshape.fill")
                .font(.title2)
        }
        .sheet(isPresented: $showingAdminView) {
            AdminView()
        }
    }
}

// MARK: - Map Panel
struct MapPanel: View {
    let selectedSession: SessionData?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var sessionLocations: [SessionLocation] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "map")
                    .foregroundColor(.green)
                Text("Session Locations")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if let selectedSession = selectedSession {
                    Text("Session: \(selectedSession.sessionId)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            Map(coordinateRegion: $region, annotationItems: sessionLocations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    VStack {
                        Image(systemName: location.isSelected ? "location.fill" : "location")
                            .foregroundColor(location.isSelected ? .red : .blue)
                            .font(.title2)
                        
                        if location.isSelected {
                            Text(location.sessionId)
                                .font(.caption)
                                .padding(4)
                                .background(Color.white)
                                .cornerRadius(4)
                                .shadow(radius: 2)
                        }
                    }
                }
            }
            .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .onChange(of: selectedSession) { session in
            updateMapForSession(session)
        }
        .task {
            loadSessionLocations()
        }
    }
    
    private func loadSessionLocations() {
        // Mock session locations
        sessionLocations = [
            SessionLocation(
                sessionId: "session_001",
                coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                isSelected: false
            ),
            SessionLocation(
                sessionId: "session_002",
                coordinate: CLLocationCoordinate2D(latitude: 37.7849, longitude: -122.4094),
                isSelected: false
            ),
            SessionLocation(
                sessionId: "session_003",
                coordinate: CLLocationCoordinate2D(latitude: 37.7649, longitude: -122.4294),
                isSelected: false
            )
        ]
    }
    
    private func updateMapForSession(_ session: SessionData?) {
        guard let session = session else {
            // Reset all selections
            sessionLocations = sessionLocations.map { location in
                var updatedLocation = location
                updatedLocation.isSelected = false
                return updatedLocation
            }
            return
        }
        
        // Update selection and center map
        sessionLocations = sessionLocations.map { location in
            var updatedLocation = location
            updatedLocation.isSelected = location.sessionId == session.sessionId
            return updatedLocation
        }
        
        if let selectedLocation = sessionLocations.first(where: { $0.sessionId == session.sessionId }) {
            region.center = selectedLocation.coordinate
        }
    }
}

// MARK: - Session Summary Panel
struct SessionSummaryPanel: View {
    let sessions: [SessionData]
    let storageStats: StorageStats?
    @Binding var selectedSession: SessionData?
    let onSessionSelected: (SessionData) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.purple)
                Text("Session Summary")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if let stats = storageStats {
                    Text("\(stats.totalSessions) sessions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack(spacing: 16) {
                // Sessions List
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent Sessions")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(sessions) { session in
                                SessionRow(
                                    session: session,
                                    isSelected: selectedSession?.id == session.id
                                ) {
                                    selectedSession = session
                                    onSessionSelected(session)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                
                // Storage Stats
                VStack(alignment: .leading, spacing: 8) {
                    Text("Storage Status")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if let stats = storageStats {
                        StorageStatsView(stats: stats)
                    } else {
                        Text("Loading...")
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// MARK: - Supporting Views and Models

struct DeviceConnection: Identifiable {
    let id: String
    let name: String
    let type: DeviceType
    let status: ConnectionStatus
    let signalStrength: Int
    let lastSeen: Date
    
    enum DeviceType {
        case palchiDevice
        case sensor
        case gateway
        
        var icon: String {
            switch self {
            case .palchiDevice: return "ipad.and.iphone"
            case .sensor: return "sensor.tag.radiowaves.forward"
            case .gateway: return "wifi.router"
            }
        }
    }
    
    enum ConnectionStatus {
        case connected
        case connecting
        case disconnected
        
        var color: Color {
            switch self {
            case .connected: return .green
            case .connecting: return .orange
            case .disconnected: return .red
            }
        }
        
        var text: String {
            switch self {
            case .connected: return "Connected"
            case .connecting: return "Connecting..."
            case .disconnected: return "Disconnected"
            }
        }
    }
}

struct DeviceConnectionRow: View {
    let connection: DeviceConnection
    
    var body: some View {
        HStack {
            Image(systemName: connection.type.icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(connection.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(connection.status.text)
                    .font(.caption)
                    .foregroundColor(connection.status.color)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "wifi")
                        .font(.caption)
                    Text("\(connection.signalStrength)%")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                
                Text(connection.lastSeen, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SessionLocation: Identifiable {
    let id = UUID()
    let sessionId: String
    let coordinate: CLLocationCoordinate2D
    var isSelected: Bool
}

struct SessionRow: View {
    let session: SessionData
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.sessionId)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    if let action = session.data["action"] as? String {
                        Text(action.capitalized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(session.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: session.synced ? "checkmark.circle.fill" : "clock.circle")
                        .foregroundColor(session.synced ? .green : .orange)
                    
                    if let duration = session.data["duration"] as? Int {
                        Text("\(duration / 60)m")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StorageStatsView: View {
    let stats: StorageStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Usage")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(stats.usagePercentage))%")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            ProgressView(value: stats.usagePercentage / 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: stats.usagePercentage > 80 ? .red : .blue))
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(stats.totalSessions)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Unsynced")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(stats.unsyncedSessions)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(stats.unsyncedSessions > 0 ? .orange : .green)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
        }
        .previewDevice("iPad Pro (12.9-inch) (6th generation)")
        .previewInterfaceOrientation(.landscapeLeft)
    }
}