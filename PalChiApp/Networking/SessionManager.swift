import Foundation

@MainActor
class SessionManager: ObservableObject {
    private let storageManager: SessionStorageManager
    private let connectivityManager: ConnectivityManager
    private let cloudSyncManager: CloudSyncManager
    private var autoSyncEnabled = true
    private var syncTimer: Timer?
    
    @Published var isOnline = false
    @Published var syncInProgress = false
    
    init(apiBaseURL: String) {
        self.storageManager = SessionStorageManager()
        self.connectivityManager = ConnectivityManager()
        self.cloudSyncManager = CloudSyncManager(apiBaseURL: apiBaseURL, sessionStorage: storageManager)
        
        setupConnectivityMonitoring()
        setupPeriodicSync()
    }
    
    private func setupConnectivityMonitoring() {
        connectivityManager.onStatusChange { [weak self] isOnline in
            Task { @MainActor in
                self?.isOnline = isOnline
                if isOnline && self?.autoSyncEnabled == true {
                    await self?.triggerSync()
                }
            }
        }
        
        isOnline = connectivityManager.isConnected
        
        // Initial sync if online
        if isOnline {
            Task {
                await triggerSync()
            }
        }
    }
    
    private func setupPeriodicSync() {
        syncTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            Task { @MainActor in
                if self?.isOnline == true && self?.autoSyncEnabled == true {
                    await self?.triggerSync()
                }
            }
        }
    }
    
    func recordSession(_ data: [String: Any], sessionId: String? = nil, userId: String? = nil) async throws -> String {
        let finalSessionId = sessionId ?? generateSessionId()
        let sessionData = SessionData(sessionId: finalSessionId, userId: userId, data: data)
        
        do {
            let localId = try await storageManager.saveSession(sessionData)
            
            // Try immediate sync if online
            if isOnline {
                Task {
                    await triggerSync()
                }
            }
            
            return localId
        } catch {
            print("Failed to record session: \(error)")
            throw error
        }
    }
    
    func triggerSync() async {
        guard isOnline else {
            print("Cannot sync: offline")
            return
        }
        
        guard !syncInProgress else {
            print("Sync already in progress")
            return
        }
        
        syncInProgress = true
        defer { syncInProgress = false }
        
        do {
            let results = try await cloudSyncManager.syncToCloud()
            print("Sync results: \(results)")
        } catch {
            print("Sync failed: \(error)")
        }
    }
    
    func getStorageStats() async throws -> StorageStats {
        return try await storageManager.getStorageStats()
    }
    
    func enableAutoSync() {
        autoSyncEnabled = true
    }
    
    func disableAutoSync() {
        autoSyncEnabled = false
    }
    
    private func generateSessionId() -> String {
        return "session_\(Int(Date().timeIntervalSince1970))_\(UUID().uuidString.prefix(8))"
    }
    
    deinit {
        syncTimer?.invalidate()
    }
}