@testable import WorldOfPAYBACK_Core

struct DummyTransactions {
    static let reweSammeln = Transaction(
        partnerDisplayName: "REWE Group",
        alias: .init(reference: "795357452000810"),
        category: 1,
        transactionDetail: .init(
            description: "Punkte sammeln",
            bookingDate: try! .init("2022-07-24T10:59:05+0200", strategy: .iso8601),
            value: .init(amount: 123,
                         currency: "PBP")
        )
    )
    
    static let otto = Transaction(
        partnerDisplayName: "OTTO Group",
        alias: .init(reference: "094844835601044"),
        category: 2,
        transactionDetail: .init(
            description: nil,
            bookingDate: try! .init("2022-07-22T10:59:05+0200", strategy: .iso8601),
            value: .init(amount: 53,
                         currency: "PBP")
        )
    )
    
    static let rewePunkte = Transaction(
        partnerDisplayName: "REWE Group",
        alias: .init(reference: "075903074248681"),
        category: 3,
        transactionDetail: .init(
            description: "Punkte sammeln",
            bookingDate: try! .init("2022-11-11T10:59:05+0200", strategy: .iso8601),
            value: .init(amount: 86,
                         currency: "PBP")
        )
    )
    
    static let weirdCurrency = Transaction(
        partnerDisplayName: "Weird Currency",
        alias: .init(reference: "2137"),
        category: 3,
        transactionDetail: .init(
            description: "Werid Currency",
            bookingDate: .now,
            value: .init(amount: 2137,
                         currency: "ZL")
        )
    )
    
    static let unordered = [rewePunkte, otto, reweSammeln]
    
    static let ordered = [otto, reweSammeln, rewePunkte]
}
