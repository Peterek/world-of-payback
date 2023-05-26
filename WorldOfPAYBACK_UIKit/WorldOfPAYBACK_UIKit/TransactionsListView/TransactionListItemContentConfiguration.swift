import UIKit
import WorldOfPAYBACK_Core

extension TransactionListItemViewModel: UIContentConfiguration {
    public func makeContentView() -> UIView & UIContentView {
        TransactionListItemContentView(viewModel: self)
    }
    
    public func updated(for state: UIConfigurationState) -> Self {
        self
    }
}
