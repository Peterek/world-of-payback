import Foundation
import Combine
import Network

class NetworkMonitor {
    var isConnected = CurrentValueSubject<Bool, Never>(false)
    
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")

    init() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected.value = path.status == .satisfied
        }
        networkMonitor.start(queue: workerQueue)
    }
}
