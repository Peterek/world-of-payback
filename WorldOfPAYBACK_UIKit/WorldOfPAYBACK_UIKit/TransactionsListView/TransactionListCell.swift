import UIKit
import WorldOfPAYBACK_Core

class TransactionListCell: UICollectionViewListCell {
    var viewModel: TransactionListItemViewModel?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        guard let viewModel else { return }
        contentConfiguration = viewModel.updated(for: state)
    }
}
