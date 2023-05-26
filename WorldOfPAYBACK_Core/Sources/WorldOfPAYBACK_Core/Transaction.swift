import Foundation

public struct Transaction: Decodable, Identifiable, Hashable {
    public let partnerDisplayName: String
    public let alias: Alias
    public let category: Int
    public let transactionDetail: TransactionDetail
    
    public var id: String { alias.reference }
    
    public init(partnerDisplayName: String, alias: Alias, category: Int, transactionDetail: TransactionDetail) {
        self.partnerDisplayName = partnerDisplayName
        self.alias = alias
        self.category = category
        self.transactionDetail = transactionDetail
    }
}

public struct Alias: Decodable, Hashable {
    public let reference: String
    
    public init(reference: String) {
        self.reference = reference
    }
}

public struct TransactionDetail: Decodable, Hashable {
    public let description: String?
    public let bookingDate: Date
    public let value: Value
    
    public init(description: String?, bookingDate: Date, value: Value) {
        self.description = description
        self.bookingDate = bookingDate
        self.value = value
    }
}

public struct Value: Decodable, Hashable {
    public let amount: Int
    public let currency: String
    
    public init(amount: Int, currency: String) {
        self.amount = amount
        self.currency = currency
    }
}

struct Transactions: Decodable {
    let items: [Transaction]
}
