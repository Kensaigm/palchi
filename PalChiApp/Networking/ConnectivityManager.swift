import Foundation
import Network

class ConnectivityManager: ObservableObject {
    @Published var isConnected = false
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var statusChangeHandlers: [(Bool) -> Void] = []
    
    init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let isConnected = path.status == .satisfied
                self?.isConnected = isConnected
                self?.notifyStatusChange(isConnected)
            }
        }
        monitor.start(queue: queue)
    }
    
    func onStatusChange(_ handler: @escaping (Bool) -> Void) {
        statusChangeHandlers.append(handler)
    }
    
    private func notifyStatusChange(_ isConnected: Bool) {
        statusChangeHandlers.forEach { handler in
            handler(isConnected)
        }
    }
    
    func testConnectivity() async -> Bool {
        guard let url = URL(string: "https://www.apple.com") else {
            return false
        }
        
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
    
    deinit {
        monitor.cancel()
    }
}