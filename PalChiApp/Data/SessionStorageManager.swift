import Foundation
import SQLite

class SessionStorageManager {
    private var db: Connection?
    private let sessions = Table("sessions")
    private let maxStorageSize: Int = 50 * 1024 * 1024 // 50MB
    
    // Table columns
    private let id = Expression<String>("id")
    private let sessionId = Expression<String>("session_id")
    private let userId = Expression<String?>("user_id")
    private let jsonData = Expression<Data>("json_data")
    private let timestamp = Expression<Date>("timestamp")
    private let synced = Expression<Bool>("synced")
    private let syncedAt = Expression<Date?>("synced_at")
    private let size = Expression<Int>("size")
    
    init() {
        setupDatabase()
    }
    
    private func setupDatabase() {
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory,
                                                       in: .userDomainMask).first!
            let dbPath = documentsPath.appendingPathComponent("palchi_sessions.sqlite3")
            
            db = try Connection(dbPath.path)
            createTable()
            print("SessionStorageManager initialized at: \(dbPath.path)")
        } catch {
            print("Database setup failed: \(error)")
        }
    }
    
    private func createTable() {
        do {
            try db?.run(sessions.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(sessionId)
                t.column(userId)
                t.column(jsonData)
                t.column(timestamp)
                t.column(synced, defaultValue: false)
                t.column(syncedAt)
                t.column(size, defaultValue: 0)
            })
            
            // Create indexes for better performance
            try db?.run(sessions.createIndex(timestamp, ifNotExists: true))
            try db?.run(sessions.createIndex(synced, ifNotExists: true))
            try db?.run(sessions.createIndex(sessionId, ifNotExists: true))
        } catch {
            print("Create table failed: \(error)")
        }
    }
    
    func saveSession(_ sessionData: SessionData) async throws -> String {
        try await checkStorageLimit()
        
        guard let db = db else {
            throw StorageError.databaseNotInitialized
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: sessionData.data)
            
            let insert = sessions.insert(
                id <- sessionData.id.uuidString,
                sessionId <- sessionData.sessionId,
                userId <- sessionData.userId,
                self.jsonData <- jsonData,
                timestamp <- sessionData.timestamp,
                synced <- sessionData.synced,
                syncedAt <- sessionData.syncedAt,
                size <- sessionData.size
            )
            
            try db.run(insert)
            print("Session saved locally: \(sessionData.sessionId)")
            return sessionData.id.uuidString
        } catch {
            print("Failed to save session: \(error)")
            throw StorageError.saveFailed(error)
        }
    }
    
    func getUnsyncedSessions() async throws -> [SessionData] {
        guard let db = db else {
            throw StorageError.databaseNotInitialized
        }
        
        do {
            let query = sessions.filter(synced == false).order(timestamp.asc)
            var results: [SessionData] = []
            
            for row in try db.prepare(query) {
                if let sessionData = try parseSessionData(from: row) {
                    results.append(sessionData)
                }
            }
            
            return results
        } catch {
            print("Failed to get unsynced sessions: \(error)")
            throw StorageError.fetchFailed(error)
        }
    }
    
    func markAsSynced(_ sessionId: String) async throws {
        guard let db = db else {
            throw StorageError.databaseNotInitialized
        }
        
        do {
            let session = sessions.filter(id == sessionId)
            try db.run(session.update(
                synced <- true,
                syncedAt <- Date()
            ))
        } catch {
            print("Failed to mark session as synced: \(error)")
            throw StorageError.updateFailed(error)
        }
    }
    
    func deleteSession(_ sessionId: String) async throws {
        guard let db = db else {
            throw StorageError.databaseNotInitialized
        }
        
        do {
            let session = sessions.filter(id == sessionId)
            try db.run(session.delete())
        } catch {
            print("Failed to delete session: \(error)")
            throw StorageError.deleteFailed(error)
        }
    }
    
    private func checkStorageLimit() async throws {
        guard let db = db else { return }
        
        do {
            let totalSize = try db.scalar(sessions.select(size.sum)) ?? 0
            
            if totalSize > maxStorageSize {
                // Remove oldest synced sessions
                let oldSyncedSessions = sessions
                    .filter(synced == true)
                    .order(timestamp.asc)
                
                for row in try db.prepare(oldSyncedSessions) {
                    try db.run(sessions.filter(id == row[id]).delete())
                    
                    let newTotalSize = try db.scalar(sessions.select(size.sum)) ?? 0
                    if newTotalSize <= Int(Double(maxStorageSize) * 0.8) {
                        break
                    }
                }
            }
        } catch {
            print("Storage limit check failed: \(error)")
        }
    }
    
    func getStorageStats() async throws -> StorageStats {
        guard let db = db else {
            throw StorageError.databaseNotInitialized
        }
        
        do {
            let totalSessions = try db.scalar(sessions.count)
            let unsyncedSessions = try db.scalar(sessions.filter(synced == false).count)
            let totalSize = try db.scalar(sessions.select(size.sum)) ?? 0
            
            return StorageStats(
                totalSessions: totalSessions,
                unsyncedSessions: unsyncedSessions,
                totalSize: totalSize,
                maxSize: maxStorageSize,
                usagePercentage: Double(totalSize) / Double(maxStorageSize) * 100
            )
        } catch {
            throw StorageError.fetchFailed(error)
        }
    }
    
    private func parseSessionData(from row: Row) throws -> SessionData? {
        do {
            let jsonData = row[self.jsonData]
            let dataDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
            
            var sessionData = SessionData(
                sessionId: row[sessionId],
                userId: row[userId],
                data: dataDict
            )
            
            // Update with stored values
            let mirror = Mirror(reflecting: sessionData)
            // Note: This is a simplified approach. In production, you'd want a more robust way to update the struct
            
            return sessionData
        } catch {
            print("Failed to parse session data: \(error)")
            return nil
        }
    }
}

enum StorageError: Error {
    case databaseNotInitialized
    case saveFailed(Error)
    case fetchFailed(Error)
    case updateFailed(Error)
    case deleteFailed(Error)
}