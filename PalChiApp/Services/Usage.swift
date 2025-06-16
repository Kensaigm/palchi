import Foundation
import SwiftUI

class PALCHIApp: ObservableObject {
    private let sessionManager: SessionManager
    @Published var isLoading = false
    @Published var storageStats: StorageStats?
    @Published var recentSessions: [SessionData] = []

    init() {
        self.sessionManager = SessionManager(apiBaseURL: "https://your-api-server.com/api")
    }

    func recordUserAction(_ action: [String: Any]) async {
        await MainActor.run {
            isLoading = true
        }

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

            // Refresh data after recording
            await loadRecentSessions()
            await checkStorageStatus()

        } catch {
            print("Failed to record session: \(error)")
        }

        await MainActor.run {
            isLoading = false
        }
    }

    func forceSync() async {
        await MainActor.run {
            isLoading = true
        }

        await sessionManager.triggerSync()

        // Refresh data after sync
        await loadRecentSessions()
        await checkStorageStatus()

        await MainActor.run {
            isLoading = false
        }
    }

    func checkStorageStatus() async {
        do {
            let stats = try await sessionManager.getStorageStats()

            await MainActor.run {
                self.storageStats = stats
            }

            print("Storage Stats:")
            print("- Total Sessions: \(stats.totalSessions)")
            print("- Unsynced Sessions: \(stats.unsyncedSessions)")
            print("- Storage Usage: \(stats.usagePercentage)%")
        } catch {
            print("Failed to get storage stats: \(error)")
        }
    }

    func loadRecentSessions() async {
        // In a real implementation, you would get recent sessions from SessionManager
        // For now, we'll create mock data that updates
        let mockSessions = createMockSessions()

        await MainActor.run {
            self.recentSessions = mockSessions
        }
    }

    private func createMockSessions() -> [SessionData] {
        // Mock data for demonstration - in real app this would come from storage
        return [
            SessionData(
                sessionId: "session_\(Int.random(in: 1000...9999))",
                userId: "user_123",
                data: [
                    "action": "meditation",
                    "duration": Int.random(in: 900...3600),
                    "location": "home",
                    "latitude": 37.7749 + Double.random(in: -0.01...0.01),
                    "longitude": -122.4194 + Double.random(in: -0.01...0.01)
                ],
                timestamp: Date().addingTimeInterval(-Double.random(in: 0...86400)),
                synced: Bool.random()
            ),
            SessionData(
                sessionId: "session_\(Int.random(in: 1000...9999))",
                userId: "user_123",
                data: [
                    "action": "breathing",
                    "duration": Int.random(in: 300...1800),
                    "location": "park",
                    "latitude": 37.7849 + Double.random(in: -0.01...0.01),
                    "longitude": -122.4094 + Double.random(in: -0.01...0.01)
                ],
                timestamp: Date().addingTimeInterval(-Double.random(in: 86400...172800)),
                synced: Bool.random()
            ),
            SessionData(
                sessionId: "session_\(Int.random(in: 1000...9999))",
                userId: "user_123",
                data: [
                    "action": "focus",
                    "duration": Int.random(in: 1200...2400),
                    "location": "office",
                    "latitude": 37.7649 + Double.random(in: -0.01...0.01),
                    "longitude": -122.4294 + Double.random(in: -0.01...0.01)
                ],
                timestamp: Date().addingTimeInterval(-Double.random(in: 172800...259200)),
                synced: Bool.random()
            )
        ]
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