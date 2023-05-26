import SwiftUI
import WorldOfPAYBACK_Core

struct TransactionDetailView: View {
    private let transaction: WorldOfPAYBACK_Core.Transaction
    
    init(transaction: WorldOfPAYBACK_Core.Transaction) {
        self.transaction = transaction
    }
    
    var body: some View {
        VStack {
            Text(transaction.partnerDisplayName)
            if let description = transaction.transactionDetail.description {
                Text(description)
            }
        }
    }
}

struct TransactionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionDetailView(
            transaction: Transaction(
                partnerDisplayName: "REWE Group",
                alias: .init(reference: "795357452000810"),
                category: 1,
                transactionDetail: .init(
                    description: "Punkte sammeln",
                    bookingDate: .now,
                    value: .init(amount: 123,
                                 currency: "PBP")
                )
            )
        )
    }
}
