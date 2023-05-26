import Foundation

extension Endpoint where Response == Transactions {
    static var transactions: Self {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return Endpoint(path: "transactions", decoder: decoder)
    }
}
