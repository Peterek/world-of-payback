import SwiftUI
import WorldOfPAYBACK_Core

struct TransactionListItemView: View {
    private let viewModel: TransactionListItemViewModel
    
    init(viewModel: TransactionListItemViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(viewModel.bookingDate)
                    .font(.caption)
                Text(viewModel.partnerDisplayName)
                if let description = viewModel.description {
                    Text(description)
                }
            }
            Spacer()
            Text(viewModel.value)
        }
    }
}

struct TransactionListItemView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionListItemView(
            viewModel: .init(
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
        )
    }
}
