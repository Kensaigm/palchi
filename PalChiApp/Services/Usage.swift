import Foundation

class PALCHIApp {
    private let sessionManager: SessionManager
    
    init() {
        self.sessionManager = SessionManager(apiBaseURL: "https://your-api-server.com/api")
    }
    
    func recordUserAction(_ action: [String: Any]) async {
        do {
            let sessionData: [String: Any] = [
                "action": action,
                "timestamp": Date().timeIntervalSince1970,
                "deviceInfo": [
                    "platform": "iOS",
                    "version": UIDevice.current.systemVersion
                ]
            ]
            
            let localId = try await sessionManager.recordSession(
                sessionData,
                userId: "user123"
            )
            
            print("Session recorded with local ID: \(localId)")
        } catch {
            print("Failed to record session: \(error)")
        }
    }
    
    func forceSync() async {
        await sessionManager.triggerSync()
    }
    
    func checkStorageStatus() async {
        do {
            let stats = try await sessionManager.getStorageStats()
            print("Storage Stats:")
            print("- Total Sessions: \(stats.totalSessions)")
            print("- Unsynced Sessions: \(stats.unsyncedSessions)")
            print("- Storage Usage: \(stats.usagePercentage)%")
        } catch {
            print("Failed to get storage stats: \(error)")
        }
    }
}

// Example usage in a SwiftUI view or UIViewController
func exampleUsage() {
    let app = PALCHIApp()
    
    Task {
        // Record a user action
        await app.recordUserAction([
            "type": "button_tap",
            "element": "login_button",
            "screen": "login"
        ])
        
        // Check storage status
        await app.checkStorageStatus()
        
        // Force sync
        await app.forceSync()
    }
}