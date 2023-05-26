import UIKit
import WorldOfPAYBACK_Core

class TransactionDetailsViewController: UIViewController {
    private let transaction: Transaction
    
    private let partnerDisplayNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    init(transaction: Transaction) {
        self.transaction = transaction
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        partnerDisplayNameLabel.font = .preferredFont(forTextStyle: .body)
        partnerDisplayNameLabel.text = transaction.partnerDisplayName
        
        descriptionLabel.font = .preferredFont(forTextStyle: .body)
        descriptionLabel.text = transaction.transactionDetail.description
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.addArrangedSubview(partnerDisplayNameLabel)
        stackView.addArrangedSubview(descriptionLabel)
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
