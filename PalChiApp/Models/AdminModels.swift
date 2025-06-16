import Foundation
import CoreLocation
import SwiftUI

// MARK: - Database Statistics Models
struct DatabaseStats {
    let totalTables: Int
    let totalRecords: Int
    let databaseSize: Int64
    let lastVacuum: Date
    let indexCount: Int
    let averageQueryTime: Double
    let connectionCount: Int
    
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: databaseSize, countStyle: .file)
    }
}

struct SessionStatistics {
    let totalSessions: Int
    let sessionsToday: Int
    let sessionsThisWeek: Int
    let sessionsThisMonth: Int
    let averageSessionDuration: Double
    let mostActiveHour: Int
    let syncSuccessRate: Double
    let errorRate: Double
    
    var formattedAverageDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: averageSessionDuration) ?? "0s"
    }
    
    var formattedSyncSuccessRate: String {
        String(format: "%.1f%%", syncSuccessRate * 100)
    }
    
    var formattedErrorRate: String {
        String(format: "%.2f%%", errorRate * 100)
    }
}

struct PerformanceStats {
    let averageResponseTime: Double
    let memoryUsage: Double // MB
    let cpuUsage: Double // Percentage
    let diskIORate: Double // MB/s
    let networkLatency: Double // ms
    let cacheHitRate: Double
    let uptime: TimeInterval
    
    var formattedUptime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .full
        return formatter.string(from: uptime) ?? "Unknown"
    }
    
    var formattedCacheHitRate: String {
        String(format: "%.1f%%", cacheHitRate * 100)
    }
}

// MARK: - Connectivity Models
struct ConnectivitySettings {
    var apiBaseURL: String = "https://your-api-server.com/api"
    var requestTimeout: Double = 30.0
    var maxRetryAttempts: Int = 3
    var autoSyncEnabled: Bool = true
    var syncInterval: Double = 300.0 // 5 minutes
    
    var formattedSyncInterval: String {
        let minutes = Int(syncInterval / 60)
        return "\(minutes) minutes"
    }
}

struct NetworkDiagnostics {
    let pingLatency: Double // ms
    let downloadSpeed: Double // Mbps
    let uploadSpeed: Double // Mbps
    let packetLoss: Double // Percentage
    let dnsResolutionTime: Double // ms
    let connectionType: String
    let isConnected: Bool
    let lastTestDate: Date
    
    var connectionQuality: ConnectionQuality {
        if !isConnected {
            return .poor
        } else if pingLatency > 100 || packetLoss > 2 {
            return .poor
        } else if pingLatency > 50 || packetLoss > 1 {
            return .fair
        } else {
            return .excellent
        }
    }
    
    enum ConnectionQuality {
        case excellent, fair, poor
        
        var color: Color {
            switch self {
            case .excellent: return .green
            case .fair: return .orange
            case .poor: return .red
            }
        }
        
        var description: String {
            switch self {
            case .excellent: return "Excellent"
            case .fair: return "Fair"
            case .poor: return "Poor"
            }
        }
    }
}

// MARK: - Device Management Models
struct DeviceEntry: Identifiable, Codable {
    let id: String
    var name: String
    let deviceId: String
    let deviceType: DeviceType
    var macAddress: String
    var ipAddress: String?
    var status: DeviceStatus
    var lastSeen: Date
    var firmwareVersion: String?
    var batteryLevel: Int?
    
    enum DeviceType: String, CaseIterable, Codable {
        case palchiDevice = "PalChi Device"
        case sensor = "Sensor"
        case gateway = "Gateway"
        case unknown = "Unknown"
        
        var icon: String {
            switch self {
            case .palchiDevice: return "ipad.and.iphone"
            case .sensor: return "sensor.tag.radiowaves.forward"
            case .gateway: return "wifi.router"
            case .unknown: return "questionmark.circle"
            }
        }
        
        var color: Color {
            switch self {
            case .palchiDevice: return .blue
            case .sensor: return .green
            case .gateway: return .purple
            case .unknown: return .gray
            }
        }
    }
    
    enum DeviceStatus: String, CaseIterable, Codable {
        case connected = "Connected"
        case disconnected = "Disconnected"
        case connecting = "Connecting"
        case error = "Error"
        
        var color: Color {
            switch self {
            case .connected: return .green
            case .disconnected: return .gray
            case .connecting: return .orange
            case .error: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .connected: return "checkmark.circle.fill"
            case .disconnected: return "circle"
            case .connecting: return "clock.circle"
            case .error: return "exclamationmark.triangle.fill"
            }
        }
    }
}

// MARK: - Location Services Models
struct LocationSettings {
    var isEnabled: Bool = false
    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest
    var currentLocation: CLLocation?
    
    var formattedCurrentLocation: String {
        guard let location = currentLocation else {
            return "Location not available"
        }
        
        return String(format: "%.6f, %.6f", location.coordinate.latitude, location.coordinate.longitude)
    }
    
    var locationAge: String {
        guard let location = currentLocation else {
            return "N/A"
        }
        
        let age = Date().timeIntervalSince(location.timestamp)
        if age < 60 {
            return "Just now"
        } else if age < 3600 {
            return "\(Int(age / 60)) minutes ago"
        } else {
            return "\(Int(age / 3600)) hours ago"
        }
    }
}

extension CLAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .authorizedAlways:
            return "Always Authorized"
        case .authorizedWhenInUse:
            return "When In Use"
        @unknown default:
            return "Unknown"
        }
    }
    
    var color: Color {
        switch self {
        case .authorizedAlways, .authorizedWhenInUse:
            return .green
        case .denied, .restricted:
            return .red
        case .notDetermined:
            return .orange
        @unknown default:
            return .gray
        }
    }
}

extension CLLocationAccuracy {
    var description: String {
        switch self {
        case kCLLocationAccuracyBestForNavigation:
            return "Best for Navigation"
        case kCLLocationAccuracyBest:
            return "Best"
        case kCLLocationAccuracyNearestTenMeters:
            return "10 meters"
        case kCLLocationAccuracyHundredMeters:
            return "100 meters"
        case kCLLocationAccuracyKilometer:
            return "1 kilometer"
        case kCLLocationAccuracyThreeKilometers:
            return "3 kilometers"
        default:
            return "Custom (\(Int(self))m)"
        }
    }
}

// MARK: - Device Lists Models
struct DeviceListEntry: Identifiable, Codable {
    let id: String
    let deviceId: String
    var deviceName: String
    var macAddress: String
    let dateAdded: Date
    let addedBy: String
    var notes: String?
    
    init(id: String = UUID().uuidString, deviceId: String, deviceName: String, macAddress: String, dateAdded: Date = Date(), addedBy: String, notes: String? = nil) {
        self.id = id
        self.deviceId = deviceId
        self.deviceName = deviceName
        self.macAddress = macAddress
        self.dateAdded = dateAdded
        self.addedBy = addedBy
        self.notes = notes
    }
}