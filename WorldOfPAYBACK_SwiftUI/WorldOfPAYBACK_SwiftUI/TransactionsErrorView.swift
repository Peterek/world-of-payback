import SwiftUI

struct TransactionsErrorView: View {
    private let error: Error
    private let retryAction: () -> Void
    
    init(_ error: Error,
         retryAction: @escaping () -> Void) {
        self.error = error
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack {
            Text(error.localizedDescription)
            Button("Retry") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct TransactionsErrorView_Previews: PreviewProvider {
    struct FakeError: Error {}
    static var previews: some View {
        TransactionsErrorView(FakeError()) {}
    }
}
