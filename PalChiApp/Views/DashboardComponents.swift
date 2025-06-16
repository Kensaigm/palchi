import SwiftUI
import MapKit

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
            
            Divider()
            
            HStack {
                Text("Size")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text(ByteCountFormatter.string(fromByteCount: Int64(stats.totalSize), countStyle: .file))
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(radius: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}