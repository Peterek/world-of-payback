import Foundation

public class DependencyContainer: ObservableObject {
    private let networkMonitor: NetworkMonitor
    public let transactionsViewModel: TransactionsViewModel
    
    @MainActor
    public init() {
        networkMonitor = NetworkMonitor()
        self.transactionsViewModel = TransactionsViewModel(
            isConnectedSubject: networkMonitor.isConnected,
            loadTransactions: {
                #warning("Replace MockSession with real one")
                return try await MockSession().request(.transactions).items
            })
    }
}
