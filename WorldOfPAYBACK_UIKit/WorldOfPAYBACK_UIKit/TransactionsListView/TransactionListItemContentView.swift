import UIKit
import WorldOfPAYBACK_Core

class TransactionListItemContentView: UIView, UIContentView {
    private var viewModel: TransactionListItemViewModel
    var configuration: UIContentConfiguration {
        get {
            viewModel
        }
        set {
            guard let viewModel = newValue as? TransactionListItemViewModel else {
                return
            }
            apply(viewModel: viewModel)
        }
       }
    
    private let bookingDateLabel = UILabel()
    private let partnerDisplayNameLabel = UILabel()
    private let valueLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    
    init(viewModel: TransactionListItemViewModel) {
        self.viewModel = viewModel
        super.init(frame: .null)
        setupViews(viewModel: viewModel)
        apply(viewModel: viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(viewModel: TransactionListItemViewModel) {
        let stackView = UIStackView()
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
        ])
        
        stackView.addArrangedSubview(bookingDateLabel)
        
        let innerStackView = UIStackView()
        innerStackView.axis = .horizontal
        innerStackView.distribution = .equalSpacing
        
        innerStackView.addArrangedSubview(partnerDisplayNameLabel)
        innerStackView.addArrangedSubview(valueLabel)
        
        stackView.addArrangedSubview(innerStackView)
        
        if viewModel.description != nil {
            stackView.addArrangedSubview(descriptionLabel)
        }
        
        bookingDateLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        partnerDisplayNameLabel.font = UIFont.preferredFont(forTextStyle: .body)
        valueLabel.font = UIFont.preferredFont(forTextStyle: .body)
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .body)
    }
    
    private func apply(viewModel: TransactionListItemViewModel) {
        self.viewModel = viewModel
        
        bookingDateLabel.text = viewModel.bookingDate
        partnerDisplayNameLabel.text = viewModel.partnerDisplayName
        valueLabel.text = viewModel.value
        descriptionLabel.text = viewModel.description
    }
}
