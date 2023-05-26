import Foundation
import Combine

@MainActor
public class TransactionsViewModel: ObservableObject {
    @Published public private(set) var transactions: [Transaction] = []
    @Published public private(set) var categoryFilters: [CategoryFilter] = []
    @Published public var selectedCategoryFilter: CategoryFilter = .all
    @Published public private(set) var totalValues: [String] = []
    @Published public private(set) var error: Error?
    @Published public private(set) var isLoading = false
    @Published public private(set) var isConnected = false
    
    private let loadTransactions: () async throws -> [Transaction]
    private let isConnectedSubject: CurrentValueSubject<Bool, Never>
    private var loadedTransactionsSubject: CurrentValueSubject<[Transaction], Never> = .init([])
    
    init(isConnectedSubject: CurrentValueSubject<Bool, Never>,
         loadTransactions: @escaping () async throws -> [Transaction]) {
        self.isConnectedSubject = isConnectedSubject
        self.loadTransactions = loadTransactions
        
        setupSubscriptions()
    }
    
    public func load() async {
        isLoading = true
        do {
            let loadedTransactions = try await loadTransactions()
            loadedTransactionsSubject.value = loadedTransactions.sorted(by: \.transactionDetail.bookingDate)
            error = nil
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    private func setupSubscriptions() {
        setupTotalValuesAssignment()
        setupTransactionsAssignment()
        setupIsConnectedAssignment()
        setupCategoryFiltersAssignment()
        setupSelectedCategoryFilterAssignment()
    }
    
    private func setupTransactionsAssignment() {
        Publishers
            .CombineLatest(loadedTransactionsSubject, $selectedCategoryFilter)
            .map { loadedTransactions, categoryFilter in
                let transactions: [Transaction]
                switch categoryFilter {
                case .all: transactions = loadedTransactions
                case .value(let value):
                    transactions = loadedTransactions.filter { $0.category == value }
                }
                return transactions
            }
            .assign(to: &$transactions)
    }
    
    private func setupCategoryFiltersAssignment() {
        loadedTransactionsSubject.map { loadedTransactions in
            var categoryFilters = [CategoryFilter.all]
            categoryFilters.append(contentsOf: Array(Set(loadedTransactions.map { $0.category })).sorted().map { CategoryFilter.value($0) })
            return categoryFilters
        }
        .assign(to: &$categoryFilters)
    }
    
    private func setupSelectedCategoryFilterAssignment() {
        $categoryFilters.compactMap({ [weak self] (categoryFilters) -> CategoryFilter? in
            guard let self else { return nil }
            guard categoryFilters.contains(self.selectedCategoryFilter) else {
                return CategoryFilter.all
            }
            return nil
        })
        .assign(to: &$selectedCategoryFilter)
    }
    
    private func setupTotalValuesAssignment() {
        $transactions.map { transactions in
            var groupedValues = [String: Int]()
            for transaction in transactions {
                let value = transaction.transactionDetail.value
                groupedValues[value.currency] = (groupedValues[value.currency] ?? 0) + value.amount
            }
            return groupedValues.map { "\($0.key) \($0.value)" }
        }
        .assign(to: &$totalValues)
    }
    
    private func setupIsConnectedAssignment() {
        isConnectedSubject
            .receive(on: DispatchQueue.main)
            .assign(to: &$isConnected)
    }
}
