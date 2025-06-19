import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {}
    
    // MARK: - Core Data Stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PalChiDataModel")
        
        // Configure for 50MB limit as specified in requirements
        let storeDescription = container.persistentStoreDescriptions.first
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // In production, handle this error appropriately
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    // MARK: - Core Data Saving Support
    
    func save() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Core Data save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func saveContext(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Core Data save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Storage Management
    
    func getDatabaseSize() -> Int64 {
        guard let storeURL = persistentContainer.persistentStoreDescriptions.first?.url else {
            return 0
        }
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: storeURL.path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            print("Error getting database size: \(error)")
            return 0
        }
    }
    
    func getStorageStats() -> StorageStats {
        let context = persistentContainer.viewContext
        
        let sessionRequest: NSFetchRequest<Session> = Session.fetchRequest()
        let unsyncedRequest: NSFetchRequest<Session> = Session.fetchRequest()
        unsyncedRequest.predicate = NSPredicate(format: "synced == NO")
        
        do {
            let totalSessions = try context.count(for: sessionRequest)
            let unsyncedSessions = try context.count(for: unsyncedRequest)
            let totalSize = Int(getDatabaseSize())
            let maxSize = 50 * 1024 * 1024 // 50MB
            let usagePercentage = Double(totalSize) / Double(maxSize) * 100.0
            
            return StorageStats(
                totalSessions: totalSessions,
                unsyncedSessions: unsyncedSessions,
                totalSize: totalSize,
                maxSize: maxSize,
                usagePercentage: usagePercentage
            )
        } catch {
            print("Error getting storage stats: \(error)")
            return StorageStats(totalSessions: 0, unsyncedSessions: 0, totalSize: 0, maxSize: 50 * 1024 * 1024, usagePercentage: 0.0)
        }
    }
    
    // MARK: - Cleanup Operations
    
    func cleanupOldSessions() {
        let context = backgroundContext
        context.perform {
            let stats = self.getStorageStats()
            
            // If we're over 80% capacity, remove oldest synced sessions
            if stats.usagePercentage > 80.0 {
                let request: NSFetchRequest<Session> = Session.fetchRequest()
                request.predicate = NSPredicate(format: "synced == YES")
                request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
                request.fetchLimit = 100 // Remove 100 oldest synced sessions
                
                do {
                    let oldSessions = try context.fetch(request)
                    for session in oldSessions {
                        context.delete(session)
                    }
                    self.saveContext(context)
                    print("Cleaned up \(oldSessions.count) old sessions")
                } catch {
                    print("Error cleaning up old sessions: \(error)")
                }
            }
        }
    }
}