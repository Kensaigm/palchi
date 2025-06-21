import Foundation

class CloudSyncManager {
    private let apiBaseURL: String
    private let sessionStorage: SessionStorageManager
    private let networkManager: NetworkManager
    private var syncInProgress = false
    private let retryAttempts = 3
    private let retryDelay: TimeInterval = 1.0
    
    init(apiBaseURL: String, sessionStorage: SessionStorageManager, networkManager: NetworkManager = NetworkManager.shared) {
        self.apiBaseURL = apiBaseURL
        self.sessionStorage = sessionStorage
        self.networkManager = networkManager
    }
    
    func syncToCloud() async throws -> SyncResult {
        guard !syncInProgress else {
            print("Sync already in progress")
            return SyncResult(successful: 0, failed: 0, errors: [])
        }
        
        syncInProgress = true
        defer { syncInProgress = false }
        
        do {
            let unsyncedSessions = try await sessionStorage.getUnsyncedSessions()
            print("Found \(unsyncedSessions.count) unsynced sessions")
            
            var successful = 0
            var failed = 0
            var errors: [SyncError] = []
            
            for session in unsyncedSessions {
                do {
                    try await uploadSession(session)
                    try await sessionStorage.markAsSynced(session.id.uuidString)
                    successful += 1
                    print("Successfully synced session \(session.sessionId)")
                } catch {
                    failed += 1
                    errors.append(SyncError(sessionId: session.sessionId, error: error.localizedDescription))
                    print("Failed to sync session \(session.sessionId): \(error)")
                }
            }
            
            let result = SyncResult(successful: successful, failed: failed, errors: errors)
            print("Sync completed: \(result)")
            return result
        } catch {
            print("Sync process failed: \(error)")
            throw error
        }
    }
    
    private func uploadSession(_ session: SessionData, attempt: Int = 1) async throws {
        guard let url = URL(string: "\(apiBaseURL)/sessions") else {
            throw NetworkError.invalidResponse
        }
        
        let sessionPayload = SessionUploadPayload(
            sessionId: session.sessionId,
            data: session.data,
            timestamp: ISO8601DateFormatter().string(from: session.timestamp),
            localId: session.id.uuidString
        )
        
        do {
            let jsonData = try JSONEncoder().encode(sessionPayload)
            let _: EmptyResponse = try await networkManager.post(
                url: url,
                headers: ["Content-Type": "application/json"],
                body: jsonData,
                responseType: EmptyResponse.self
            )
            
            print("Session uploaded successfully: \(session.sessionId)")
        } catch {
            if attempt < retryAttempts {
                print("Retrying upload for session \(session.sessionId), attempt \(attempt + 1)")
                try await Task.sleep(nanoseconds: UInt64(retryDelay * Double(attempt) * 1_000_000_000))
                try await uploadSession(session, attempt: attempt + 1)
            } else {
                throw error
            }
        }
    }
    
    func uploadBatch(_ sessions: [SessionData]) async throws {
        guard let url = URL(string: "\(apiBaseURL)/sessions/batch") else {
            throw NetworkError.invalidResponse
        }
        
        let batchPayload = BatchUploadPayload(
            sessions: sessions.map { session in
                SessionUploadPayload(
                    sessionId: session.sessionId,
                    data: session.data,
                    timestamp: ISO8601DateFormatter().string(from: session.timestamp),
                    localId: session.id.uuidString
                )
            }
        )
        
        do {
            let jsonData = try JSONEncoder().encode(batchPayload)
            let _: EmptyResponse = try await networkManager.post(
                url: url,
                headers: ["Content-Type": "application/json"],
                body: jsonData,
                responseType: EmptyResponse.self
            )
            
            print("Batch upload successful")
        } catch {
            print("Batch upload failed: \(error)")
            throw error
        }
    }
}

// MARK: - Upload Payload Models

private struct SessionUploadPayload: Codable {
    let sessionId: String
    let data: [String: Any]
    let timestamp: String
    let localId: String
    
    enum CodingKeys: String, CodingKey {
        case sessionId, data, timestamp, localId
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sessionId, forKey: .sessionId)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(localId, forKey: .localId)
        
        // Convert [String: Any] to JSON data and then back to a dictionary that can be encoded
        let jsonData = try JSONSerialization.data(withJSONObject: data)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData)
        try container.encode(AnyCodable(jsonObject), forKey: .data)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sessionId = try container.decode(String.self, forKey: .sessionId)
        timestamp = try container.decode(String.self, forKey: .timestamp)
        localId = try container.decode(String.self, forKey: .localId)
        
        let anyData = try container.decode(AnyCodable.self, forKey: .data)
        data = anyData.value as? [String: Any] ?? [:]
    }
    
    init(sessionId: String, data: [String: Any], timestamp: String, localId: String) {
        self.sessionId = sessionId
        self.data = data
        self.timestamp = timestamp
        self.localId = localId
    }
}

private struct BatchUploadPayload: Codable {
    let sessions: [SessionUploadPayload]
}

// MARK: - Helper for Any type encoding/decoding

private struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let doubleValue = value as? Double {
            try container.encode(doubleValue)
        } else if let stringValue = value as? String {
            try container.encode(stringValue)
        } else if let boolValue = value as? Bool {
            try container.encode(boolValue)
        } else if let arrayValue = value as? [Any] {
            try container.encode(arrayValue.map(AnyCodable.init))
        } else if let dictValue = value as? [String: Any] {
            try container.encode(dictValue.mapValues(AnyCodable.init))
        } else {
            try container.encodeNil()
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue.map { $0.value }
        } else if let dictValue = try? container.decode([String: AnyCodable].self) {
            value = dictValue.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }
}