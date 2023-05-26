import XCTest
@testable import WorldOfPAYBACK_Core
import Combine

class TransactionsViewModelTests: XCTestCase {
    private var tested: TransactionsViewModel!
    private var isConnectedSubject: CurrentValueSubject<Bool, Never>!
    private var loadTransactions: (() async throws -> [Transaction])!
    private var continuation: CheckedContinuation<[Transaction], Never>?
    
    override func setUp() async throws {
        try await super.setUp()
        isConnectedSubject = .some(.init(true))
        loadTransactions = { [] }
        await setupTested()
    }
    
    override func tearDown() {
        tested = nil
        loadTransactions = nil
        isConnectedSubject = nil
        continuation = nil
    }
    
    func testIsConnectedTrue() async {
        // Given
        
        // When
        let isConnected = await tested.isConnected
        
        // Then
        XCTAssertTrue(isConnected)
    }
    
    func testIsConnectedFalse() async {
        // Given
        isConnectedSubject.value = false
        
        // When
        let isConnected = await tested.isConnected
        
        // Then
        XCTAssertFalse(isConnected)
    }
    
    func testInitialIsLoadingFalse() async {
        // Given
        
        // When
        let isLoading = await tested.isLoading
        
        // Then
        XCTAssertFalse(isLoading)
    }
    
    func testLoadIsLoadingTrue() async {
        // Given
        var isLoading = false
        loadTransactions = { [weak self] in
            guard let self else { return [] }
            isLoading = await self.tested.isLoading
            return []
        }
        await setupTested()
        
        // When
        await tested.load()
        
        // Then
        XCTAssertTrue(isLoading)
    }
    
    func testAfterLoadIsLoadingFalse() async {
        // Given
        
        // When
        await tested.load()
        let isLoading = await tested.isLoading
        
        // Then
        XCTAssertFalse(isLoading)
    }
    
    func testInitialErrorNil() async {
        // Given
        
        // When
        let error = await tested.error
        
        // Then
        XCTAssertNil(error)
    }
    
    func testLoadSuccessErrorNil() async {
        // Given
        
        // When
        await tested.load()
        let error = await tested.error
        
        // Then
        XCTAssertNil(error)
    }
    
    func testLoadFailsErrorMatches() async throws {
        // Given
        let dummyError = DummyError()
        loadTransactions = {
            throw dummyError
        }
        await setupTested()
        
        // When
        await tested.load()
        let error = await tested.error
        
        // Then
        XCTAssertEqual(error as? DummyError, dummyError)
    }
    
    func testInitialTransactionsEmpty() async {
        // Given
        
        // When
        let transactions = await tested.transactions
        
        // Then
        XCTAssertTrue(transactions.isEmpty)
    }
    
    func testLoadedTransactionsAreOrdered() async {
        // Given
        loadTransactions = {
            DummyTransactions.unordered
        }
        await setupTested()
        
        // When
        await tested.load()
        let transactions = await tested.transactions
        
        // Then
        XCTAssertEqual(transactions, DummyTransactions.ordered)
    }
    
    func testLoadedTransactionsAreFilteredByCategory() async {
        // Given
        loadTransactions = {
            DummyTransactions.unordered
        }
        await setupTested()
        
        // When
        await MainActor.run {
            tested.selectedCategoryFilter = .value(2)
        }
        await tested.load()
        let transactions = await tested.transactions
        
        // Then
        XCTAssertEqual(transactions, [DummyTransactions.otto])
    }
    
    func testLoadedTransactionsAreFilteredByCategoryAfterLoad() async {
        // Given
        loadTransactions = {
            DummyTransactions.unordered
        }
        await setupTested()
        
        // When
        await tested.load()
        await MainActor.run {
            tested.selectedCategoryFilter = .value(2)
        }
        let transactions = await tested.transactions
        
        // Then
        XCTAssertEqual(transactions, [DummyTransactions.otto])
    }
    
    func testCategoryFiltersHaveAllCategories() async {
        // Given
        loadTransactions = {
            DummyTransactions.unordered
        }
        await setupTested()
        
        // When
        await tested.load()
        let categoryFilters = await tested.categoryFilters
        
        // Then
        XCTAssertEqual(categoryFilters, [.all, .value(1), .value(2), .value(3)])
    }
    
    func testCategoryFiltersHaveSomeCategories() async {
        // Given
        loadTransactions = {
            [DummyTransactions.otto]
        }
        await setupTested()
        
        // When
        await tested.load()
        let categoryFilters = await tested.categoryFilters
        
        // Then
        XCTAssertEqual(categoryFilters, [.all, .value(2)])
    }
    
    func testTotalValuesSumsAllValues() async {
        // Given
        loadTransactions = {
            DummyTransactions.unordered
        }
        await setupTested()
        
        // When
        await tested.load()
        let totalValues = await tested.totalValues
        
        // Then
        XCTAssertEqual(totalValues, ["PBP 262"])
    }
    
    func testTotalValuesSumsFilteredValues() async {
        // Given
        loadTransactions = {
            DummyTransactions.unordered
        }
        await setupTested()
        
        // When
        await tested.load()
        await MainActor.run {
            tested.selectedCategoryFilter = .value(2)
        }
        let totalValues = await tested.totalValues
        
        // Then
        XCTAssertEqual(totalValues, ["PBP 53"])
    }
    
    func testTotalValuesSumsAllValuesWithDifferentCurrencies() async {
        // Given
        loadTransactions = {
            [DummyTransactions.unordered, [DummyTransactions.weirdCurrency]].flatMap { $0 }
        }
        await setupTested()
        
        // When
        await tested.load()
        let totalValues = await tested.totalValues
        
        // Then
        XCTAssertEqual(Set(totalValues), Set(["PBP 262", "ZL 2137"]))
    }
}

extension TransactionsViewModelTests {
    private func setupTested() async {
        tested = await TransactionsViewModel(
            isConnectedSubject: isConnectedSubject,
            loadTransactions: loadTransactions)
    }
}
