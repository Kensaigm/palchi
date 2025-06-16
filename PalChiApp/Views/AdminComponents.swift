import SwiftUI
import CoreLocation

// MARK: - Reusable Admin Components

struct AdminSectionCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Divider()
            
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
    }
}

// MARK: - Database Statistics Components

struct DatabaseOverviewContent: View {
    let stats: DatabaseStats
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                StatItem(title: "Tables", value: "\(stats.totalTables)")
                Spacer()
                StatItem(title: "Records", value: "\(stats.totalRecords)")
                Spacer()
                StatItem(title: "Size", value: stats.formattedSize)
            }
            
            Divider()
            
            HStack {
                StatItem(title: "Indexes", value: "\(stats.indexCount)")
                Spacer()
                StatItem(title: "Connections", value: "\(stats.connectionCount)")
                Spacer()
                StatItem(title: "Avg Query", value: String(format: "%.3fs", stats.averageQueryTime))
            }
            
            Divider()
            
            HStack {
                Text("Last Vacuum:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(stats.lastVacuum, style: .relative)
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
    }
}

struct SessionStatisticsContent: View {
    let stats: SessionStatistics
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                StatItem(title: "Total", value: "\(stats.totalSessions)")
                Spacer()
                StatItem(title: "Today", value: "\(stats.sessionsToday)")
                Spacer()
                StatItem(title: "This Week", value: "\(stats.sessionsThisWeek)")
            }
            
            Divider()
            
            HStack {
                StatItem(title: "This Month", value: "\(stats.sessionsThisMonth)")
                Spacer()
                StatItem(title: "Avg Duration", value: stats.formattedAverageDuration)
                Spacer()
                StatItem(title: "Peak Hour", value: "\(stats.mostActiveHour):00")
            }
            
            Divider()
            
            HStack {
                StatItem(title: "Sync Success", value: stats.formattedSyncSuccessRate, color: .green)
                Spacer()
                StatItem(title: "Error Rate", value: stats.formattedErrorRate, color: stats.errorRate > 0.05 ? .red : .green)
            }
        }
    }
}

struct StorageAnalysisContent: View {
    let stats: StorageStats
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Storage Usage")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(Int(stats.usagePercentage))%")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(stats.usagePercentage > 80 ? .red : .blue)
            }
            
            ProgressView(value: stats.usagePercentage / 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: stats.usagePercentage > 80 ? .red : .blue))
            
            HStack {
                StatItem(title: "Total Sessions", value: "\(stats.totalSessions)")
                Spacer()
                StatItem(title: "Unsynced", value: "\(stats.unsyncedSessions)", color: stats.unsyncedSessions > 0 ? .orange : .green)
            }
            
            HStack {
                StatItem(title: "Used Space", value: ByteCountFormatter.string(fromByteCount: Int64(stats.totalSize), countStyle: .file))
                Spacer()
                StatItem(title: "Max Space", value: ByteCountFormatter.string(fromByteCount: Int64(stats.maxSize), countStyle: .file))
            }
        }
    }
}

struct PerformanceMetricsContent: View {
    let stats: PerformanceStats
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                StatItem(title: "Response Time", value: String(format: "%.2fs", stats.averageResponseTime))
                Spacer()
                StatItem(title: "Memory", value: String(format: "%.1f MB", stats.memoryUsage))
                Spacer()
                StatItem(title: "CPU", value: String(format: "%.1f%%", stats.cpuUsage))
            }
            
            Divider()
            
            HStack {
                StatItem(title: "Disk I/O", value: String(format: "%.1f MB/s", stats.diskIORate))
                Spacer()
                StatItem(title: "Latency", value: String(format: "%.0f ms", stats.networkLatency))
                Spacer()
                StatItem(title: "Cache Hit", value: stats.formattedCacheHitRate, color: .green)
            }
            
            Divider()
            
            HStack {
                Text("Uptime:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(stats.formattedUptime)
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    init(title: String, value: String, color: Color = .primary) {
        self.title = title
        self.value = value
        self.color = color
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

// MARK: - Connectivity Components

struct NetworkStatusContent: View {
    @ObservedObject var adminManager: AdminManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "wifi")
                    .foregroundColor(.blue)
                
                Text("Network Connection")
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("Connected")
                    .foregroundColor(.green)
                    .fontWeight(.medium)
            }
            
            if let diagnostics = adminManager.networkDiagnostics {
                HStack {
                    StatItem(title: "Latency", value: String(format: "%.0f ms", diagnostics.pingLatency))
                    Spacer()
                    StatItem(title: "Quality", value: diagnostics.connectionQuality.description, color: diagnostics.connectionQuality.color)
                    Spacer()
                    StatItem(title: "Type", value: diagnostics.connectionType)
                }
            }
            
            Button("Test Connection") {
                Task {
                    await adminManager.runNetworkDiagnostics()
                }
            }
            .buttonStyle(.bordered)
            .disabled(adminManager.isLoading)
        }
    }
}

struct SyncSettingsContent: View {
    @ObservedObject var adminManager: AdminManager
    
    var body: some View {
        VStack(spacing: 12) {
            Toggle("Auto Sync", isOn: Binding(
                get: { adminManager.connectivitySettings.autoSyncEnabled },
                set: { newValue in
                    var settings = adminManager.connectivitySettings
                    settings.autoSyncEnabled = newValue
                    Task {
                        await adminManager.updateConnectivitySettings(settings)
                    }
                }
            ))
            
            HStack {
                Text("Sync Interval:")
                    .fontWeight(.medium)
                Spacer()
                Text(adminManager.connectivitySettings.formattedSyncInterval)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Last Sync:")
                    .fontWeight(.medium)
                Spacer()
                Text("2 minutes ago")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct NetworkDiagnosticsContent: View {
    let diagnostics: NetworkDiagnostics
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                StatItem(title: "Download", value: String(format: "%.1f Mbps", diagnostics.downloadSpeed))
                Spacer()
                StatItem(title: "Upload", value: String(format: "%.1f Mbps", diagnostics.uploadSpeed))
                Spacer()
                StatItem(title: "Packet Loss", value: String(format: "%.1f%%", diagnostics.packetLoss))
            }
            
            HStack {
                Text("Last Test:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(diagnostics.lastTestDate, style: .relative)
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
    }
}

// MARK: - Device Management Components

struct DeviceEntryRow: View {
    let device: DeviceEntry
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: device.deviceType.icon)
                    .foregroundColor(device.deviceType.color)
                    .font(.title2)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(device.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(device.deviceId)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let ip = device.ipAddress {
                        Text(ip)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Image(systemName: device.status.icon)
                            .foregroundColor(device.status.color)
                        Text(device.status.rawValue)
                            .font(.caption)
                            .foregroundColor(device.status.color)
                    }
                    
                    Text(device.lastSeen, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    if let battery = device.batteryLevel {
                        HStack(spacing: 2) {
                            Image(systemName: "battery.25")
                                .font(.caption2)
                            Text("\(battery)%")
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Location Services Components

struct LocationSettingsContent: View {
    @ObservedObject var adminManager: AdminManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Desired Accuracy:")
                    .fontWeight(.medium)
                Spacer()
                Text(adminManager.locationSettings.desiredAccuracy.description)
                    .foregroundColor(.secondary)
            }
            
            Toggle("Background Location", isOn: .constant(false))
                .disabled(true)
            
            Toggle("Location History", isOn: .constant(true))
        }
    }
}

struct CurrentLocationContent: View {
    @ObservedObject var adminManager: AdminManager
    
    var body: some View {
        VStack(spacing: 12) {
            if let location = adminManager.locationSettings.currentLocation {
                HStack {
                    Text("Coordinates:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(adminManager.locationSettings.formattedCurrentLocation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Accuracy:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(String(format: "±%.0fm", location.horizontalAccuracy))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Age:")
                        .fontWeight(.medium)
                    Spacer()
                    Text(adminManager.locationSettings.locationAge)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "location.slash")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    
                    Text("Location not available")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct LocationHistoryContent: View {
    @ObservedObject var adminManager: AdminManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Locations Recorded:")
                    .fontWeight(.medium)
                Spacer()
                Text("47")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Last 24 Hours:")
                    .fontWeight(.medium)
                Spacer()
                Text("12")
                    .foregroundColor(.secondary)
            }
            
            Button("View Location History") {
                // TODO: Show location history
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Device Lists Components

struct DeviceListRow: View {
    let device: DeviceListEntry
    let listType: DeviceListsView.DeviceListType
    
    var body: some View {
        HStack {
            Image(systemName: listType.icon)
                .foregroundColor(listType.color)
                .font(.title2)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(device.deviceName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(device.deviceId)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(device.macAddress)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Added by \(device.addedBy)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(device.dateAdded, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}