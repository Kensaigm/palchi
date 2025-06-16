import Foundation
import Alamofire

class CloudSyncManager {
    private let apiBaseURL: String
    private let sessionStorage: SessionStorageManager
    private var syncInProgress = false
    private let retryAttempts = 3
    private let retryDelay: TimeInterval = 1.0
    
    init(apiBaseURL: String, sessionStorage: SessionStorageManager) {
        self.apiBaseURL = apiBaseURL
        self.sessionStorage = sessionStorage
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
        let url = "\(apiBaseURL)/sessions"
        
        let parameters: [String: Any] = [
            "sessionId": session.sessionId,
            "data": session.data,
            "timestamp": ISO8601DateFormatter().string(from: session.timestamp),
            "localId": session.id.uuidString
        ]
        
        do {
            let response = try await AF.request(url,
                                              method: .post,
                                              parameters: parameters,
                                              encoding: JSONEncoding.default,
                                              headers: ["Content-Type": "application/json"])
                .validate()
                .serializingData()
                .value
            
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
        let url = "\(apiBaseURL)/sessions/batch"
        
        let batchData = sessions.map { session in
            [
                "sessionId": session.sessionId,
                "data": session.data,
                "timestamp": ISO8601DateFormatter().string(from: session.timestamp),
                "localId": session.id.uuidString
            ]
        }
        
        let parameters = ["sessions": batchData]
        
        do {
            let response = try await AF.request(url,
                                              method: .post,
                                              parameters: parameters,
                                              encoding: JSONEncoding.default,
                                              headers: ["Content-Type": "application/json"])
                .validate()
                .serializingData()
                .value
            
            print("Batch upload successful")
        } catch {
            print("Batch upload failed: \(error)")
            throw error
        }
    }
}