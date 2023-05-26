import SwiftUI
import WorldOfPAYBACK_Core

struct TransactionsView: View {
    @ObservedObject private var viewModel: TransactionsViewModel
    @State private var isRefreshing = false
    
    init(viewModel: TransactionsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        conditionalView
            .task {
                await viewModel.load()
            }
    }
    
    @ViewBuilder
    var conditionalView: some View {
        if !viewModel.isConnected {
            Text("No Internet Connection")
        } else if viewModel.isLoading && !isRefreshing {
            ProgressView()
        } else if let error = viewModel.error {
            TransactionsErrorView(error) {
                Task {
                    await viewModel.load()
                }
            }
        } else {
            NavigationStack {
                listView
                    .safeAreaInset(edge: .top) {
                        categoriesFilterView
                    }
                    .safeAreaInset(edge: .bottom) {
                        totalView
                    }
                    .refreshable {
                        isRefreshing = true
                        await viewModel.load()
                        isRefreshing = false
                    }
            }
        }
    }
    
    var listView: some View {
        List {
            ForEach(viewModel.transactions) { transaction in
                NavigationLink(value: transaction) {
                    TransactionListItemView(viewModel: .init(transaction: transaction))
                }
            }
        }
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Transaction.self, destination: { transaction in
            TransactionDetailView(transaction: transaction)
        })
        .listStyle(.plain)
    }
    
    var categoriesFilterView: some View {
        @ViewBuilder
        func viewForCategory(_ category: CategoryFilter) -> some View {
            switch category {
            case .all:
                Text("All")
            case .value(let value):
                Text(String(value))
            }
        }
        return Picker("Category", selection: $viewModel.selectedCategoryFilter) {
            ForEach(viewModel.categoryFilters, id: \.self) { categoryFilter in
                viewForCategory(categoryFilter).tag(categoryFilter)
            }
        }
        .pickerStyle(.segmented)
        .background(.ultraThinMaterial)
    }
    
    var totalView: some View {
        HStack {
            Text("Total")
            Spacer()
            VStack {
                ForEach(viewModel.totalValues, id: \.self) { totalValue in
                    Text(totalValue)
                }
            }
        }
        .padding([.horizontal, .top])
        .background(.ultraThinMaterial)
    }
}

struct TransactionsView_Previews: PreviewProvider {
    static var previews: some View {
        let dependencyContainer = DependencyContainer()
        TransactionsView(viewModel: dependencyContainer.transactionsViewModel)
    }
}
