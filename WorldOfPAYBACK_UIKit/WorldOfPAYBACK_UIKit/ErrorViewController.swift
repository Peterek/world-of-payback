import UIKit

class ErrorViewController: UIViewController {
    private let errorLabel = UILabel()
    private var retryButton: UIButton?
    private let stackView = UIStackView()
    private var retryHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        errorLabel.font = .preferredFont(forTextStyle: .body)
        errorLabel.numberOfLines = 0
        let action = UIAction(title: "Retry") { [weak self] _ in
            self?.retryHandler?()
        }
        retryButton = UIButton(configuration: .filled(), primaryAction: action)
        
        stackView.axis = .vertical
        stackView.addArrangedSubview(errorLabel)
        stackView.addArrangedSubview(retryButton!)
        view.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    func setup(text: String, retryAction: @escaping () -> Void) {
        errorLabel.text = text
        retryHandler = retryAction
    }
}
