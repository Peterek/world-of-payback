import Foundation

@MainActor
public class TransactionListItemViewModel: Hashable {
    private let transaction: Transaction
    
    public var bookingDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from: transaction.transactionDetail.bookingDate)
    }
    public var partnerDisplayName: String { transaction.partnerDisplayName }
    public var description: String? { transaction.transactionDetail.description }
    public var value: String { "\(String(transaction.transactionDetail.value.amount)) \(transaction.transactionDetail.value.currency)" }
    
    public init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    nonisolated public static func == (lhs: TransactionListItemViewModel, rhs: TransactionListItemViewModel) -> Bool {
        lhs.transaction == rhs.transaction
    }
    
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(transaction)
    }
}
