import Foundation
import CoreData

class SessionStorageManager {
    private let coreDataStack = CoreDataStack.shared
    private let maxStorageSize: Int = 50 * 1024 * 1024 // 50MB
    
    init() {
        print("SessionStorageManager initialized with Core Data")
    }
    
    // MARK: - Session Management
    
    func saveSession(_ sessionData: SessionData) -> Bool {
        let context = coreDataStack.context
        
        // Check storage capacity before saving
        let stats = getStorageStats()
        if stats.usagePercentage > 95.0 {
            print("Storage nearly full, cleaning up old sessions")
            coreDataStack.cleanupOldSessions()
        }
        
        let session = Session(context: context)
        session.id = sessionData.id
        session.sessionId = sessionData.sessionId
        session.userId = sessionData.userId
        session.timestamp = sessionData.timestamp
        session.synced = sessionData.synced
        session.syncedAt = sessionData.syncedAt
        session.size = Int32(sessionData.size)
        
        // Convert data dictionary to JSON Data
        do {
            session.jsonData = try JSONSerialization.data(withJSONObject: sessionData.data)
        } catch {
            print("Error serializing session data: \(error)")
            return false
        }
        
        coreDataStack.save()
        return true
    }
    
    func getSession(by id: UUID) -> SessionData? {
        let context = coreDataStack.context
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            let sessions = try context.fetch(request)
            return sessions.first?.toSessionData()
        } catch {
            print("Error fetching session: \(error)")
            return nil
        }
    }
    
    func getAllSessions() -> [SessionData] {
        let context = coreDataStack.context
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            let sessions = try context.fetch(request)
            return sessions.compactMap { $0.toSessionData() }
        } catch {
            print("Error fetching all sessions: \(error)")
            return []
        }
    }
    
    func getRecentSessions(limit: Int = 10) -> [SessionData] {
        let context = coreDataStack.context
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = limit
        
        do {
            let sessions = try context.fetch(request)
            return sessions.compactMap { $0.toSessionData() }
        } catch {
            print("Error fetching recent sessions: \(error)")
            return []
        }
    }
    
    func getUnsyncedSessions() -> [SessionData] {
        let context = coreDataStack.context
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.predicate = NSPredicate(format: "synced == NO")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        
        do {
            let sessions = try context.fetch(request)
            return sessions.compactMap { $0.toSessionData() }
        } catch {
            print("Error fetching unsynced sessions: \(error)")
            return []
        }
    }
    
    func markSessionAsSynced(_ sessionId: String) -> Bool {
        let context = coreDataStack.context
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.predicate = NSPredicate(format: "sessionId == %@", sessionId)
        request.fetchLimit = 1
        
        do {
            let sessions = try context.fetch(request)
            if let session = sessions.first {
                session.synced = true
                session.syncedAt = Date()
                coreDataStack.save()
                return true
            }
        } catch {
            print("Error marking session as synced: \(error)")
        }
        return false
    }
    
    func deleteSession(_ sessionId: String) -> Bool {
        let context = coreDataStack.context
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.predicate = NSPredicate(format: "sessionId == %@", sessionId)
        
        do {
            let sessions = try context.fetch(request)
            for session in sessions {
                context.delete(session)
            }
            coreDataStack.save()
            return true
        } catch {
            print("Error deleting session: \(error)")
            return false
        }
    }
    
    func deleteAllSessions() -> Bool {
        let context = coreDataStack.context
        let request: NSFetchRequest<NSFetchRequestResult> = Session.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            coreDataStack.save()
            return true
        } catch {
            print("Error deleting all sessions: \(error)")
            return false
        }
    }
    
    // MARK: - Storage Statistics
    
    func getStorageStats() -> StorageStats {
        return coreDataStack.getStorageStats()
    }
    
    func getDatabaseSize() -> Int64 {
        return coreDataStack.getDatabaseSize()
    }
    
    // MARK: - Maintenance
    
    func performMaintenance() {
        coreDataStack.cleanupOldSessions()
    }
    
    func vacuum() {
        // Core Data handles optimization automatically, but we can trigger cleanup
        coreDataStack.cleanupOldSessions()
    }
    
    // MARK: - Search and Filtering
    
    func searchSessions(query: String) -> [SessionData] {
        let context = coreDataStack.context
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.predicate = NSPredicate(format: "sessionId CONTAINS[cd] %@ OR userId CONTAINS[cd] %@", query, query)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            let sessions = try context.fetch(request)
            return sessions.compactMap { $0.toSessionData() }
        } catch {
            print("Error searching sessions: \(error)")
            return []
        }
    }
    
    func getSessionsInDateRange(from startDate: Date, to endDate: Date) -> [SessionData] {
        let context = coreDataStack.context
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp <= %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            let sessions = try context.fetch(request)
            return sessions.compactMap { $0.toSessionData() }
        } catch {
            print("Error fetching sessions in date range: \(error)")
            return []
        }
    }
    
    func getSessionsByUser(_ userId: String) -> [SessionData] {
        let context = coreDataStack.context
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", userId)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            let sessions = try context.fetch(request)
            return sessions.compactMap { $0.toSessionData() }
        } catch {
            print("Error fetching sessions by user: \(error)")
            return []
        }
    }
}

// MARK: - Session Core Data Extension

extension Session {
    func toSessionData() -> SessionData? {
        guard let id = self.id,
              let sessionId = self.sessionId,
              let timestamp = self.timestamp,
              let jsonData = self.jsonData else {
            return nil
        }
        
        do {
            let data = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
            
            var sessionData = SessionData(sessionId: sessionId, userId: self.userId, data: data)
            
            // Update the properties that can't be set in init
            let mirror = Mirror(reflecting: sessionData)
            if let idProperty = mirror.children.first(where: { $0.label == "id" }) {
                // Use reflection or create a new initializer to set the id
                // For now, we'll create a new SessionData with the correct values
                return SessionData(
                    id: id,
                    sessionId: sessionId,
                    userId: self.userId,
                    data: data,
                    timestamp: timestamp,
                    synced: self.synced,
                    syncedAt: self.syncedAt,
                    size: Int(self.size)
                )
            }
            
            return sessionData
        } catch {
            print("Error deserializing session data: \(error)")
            return nil
        }
    }
}

// MARK: - SessionData Extension for Core Data

extension SessionData {
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
}