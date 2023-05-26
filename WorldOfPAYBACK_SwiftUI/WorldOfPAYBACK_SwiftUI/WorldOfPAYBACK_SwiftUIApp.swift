import SwiftUI
import WorldOfPAYBACK_Core

@main
struct WorldOfPAYBACK_SwiftUIApp: App {
    @StateObject private var dependencyContainer = DependencyContainer()
    
    var body: some Scene {
        WindowGroup {
            TransactionsView(viewModel: dependencyContainer.transactionsViewModel)
        }
    }
}
