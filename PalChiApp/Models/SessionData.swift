import Foundation

struct SessionData: Codable {
    let id: UUID
    let sessionId: String
    let userId: String?
    let data: [String: Any]
    let timestamp: Date
    let synced: Bool
    let syncedAt: Date?
    let size: Int
    
    init(sessionId: String, userId: String? = nil, data: [String: Any]) {
        self.id = UUID()
        self.sessionId = sessionId
        self.userId = userId
        self.data = data
        self.timestamp = Date()
        self.synced = false
        self.syncedAt = nil
        self.size = Self.calculateSize(data: data)
    }
    
    // Core Data compatible initializer
    init(id: UUID, sessionId: String, userId: String?, data: [String: Any], timestamp: Date, synced: Bool, syncedAt: Date?, size: Int) {
        self.id = id
        self.sessionId = sessionId
        self.userId = userId
        self.data = data
        self.timestamp = timestamp
        self.synced = synced
        self.syncedAt = syncedAt
        self.size = size
    }
    
    private static func calculateSize(data: [String: Any]) -> Int {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            return jsonData.count
        } catch {
            return 0
        }
    }
    
    // Custom coding keys to handle [String: Any]
    enum CodingKeys: String, CodingKey {
        case id, sessionId, userId, timestamp, synced, syncedAt, size
        case data = "jsonData"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        sessionId = try container.decode(String.self, forKey: .sessionId)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        synced = try container.decode(Bool.self, forKey: .synced)
        syncedAt = try container.decodeIfPresent(Date.self, forKey: .syncedAt)
        size = try container.decode(Int.self, forKey: .size)
        
        let jsonData = try container.decode(Data.self, forKey: .data)
        data = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sessionId, forKey: .sessionId)
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(synced, forKey: .synced)
        try container.encodeIfPresent(syncedAt, forKey: .syncedAt)
        try container.encode(size, forKey: .size)
        
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        try container.encode(jsonData, forKey: .data)
    }
}

struct StorageStats {
    let totalSessions: Int
    let unsyncedSessions: Int
    let totalSize: Int
    let maxSize: Int
    let usagePercentage: Double
}

struct SyncResult {
    let successful: Int
    let failed: Int
    let errors: [SyncError]
}

struct SyncError {
    let sessionId: String
    let error: String
}

// MARK: - Device Data Models

struct DeviceData {
    let id: UUID
    let deviceId: String
    let name: String
    let type: DeviceType
    let firmwareVersion: String?
    let batteryLevel: Int?
    let lastSeen: Date?
    let isConnected: Bool
    let signalStrength: Int?
    
    enum DeviceType: String, CaseIterable {
        case palchiDevice = "PalChi Device"
        case sensor = "Sensor"
        case gateway = "Gateway"
    }
}

struct LocationData {
    let id: UUID
    let latitude: Double
    let longitude: Double
    let altitude: Double?
    let accuracy: Double?
    let timestamp: Date
    let locationName: String?
}

struct SyncLogData {
    let id: UUID
    let sessionId: String
    let syncAttemptDate: Date
    let successful: Bool
    let errorMessage: String?
    let retryCount: Int
}