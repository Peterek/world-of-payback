import UIKit
import WorldOfPAYBACK_Core
import Combine

class TransactionsViewController: UIViewController {
    private let viewModel: TransactionsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let refreshControl = UIRefreshControl()
    private let filterSegmentedControl = UISegmentedControl()
    private var totalValuesStackView: UIStackView?
    private let errorViewController = ErrorViewController()
    private lazy var collectionView = makeCollectionView()
    private lazy var dataSource = makeDataSource()
    private var loadingTask: Task<Void, Never>?
    
    init(viewModel: TransactionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Transactions"
        
        setupCollectionView()
        setupRefreshControl()
        setupFilterSegmentedControl()
        setupBottomTotalView()
        
        setupSubscriptions()
        
        initialLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.contentInset = .init(top: filterSegmentedControl.bounds.height, left: 0, bottom: 0, right:0)
    }
    
    private func setupSubscriptions() {
        setupTransactionsSubscription()
        setupCategoryFiltersSubscription()
        setupTotalValuesSubscription()
        setupErrorSubscription()
    }
    
    private func setupTransactionsSubscription() {
        viewModel.$transactions.sink { [weak self] transactions in
            self?.updateList(transactions: transactions)
        }.store(in: &cancellables)
    }
    
    private func setupCategoryFiltersSubscription() {
        viewModel.$categoryFilters.sink { [weak self] categoryFilters in
            self?.filterSegmentedControl.removeAllSegments()
            var segment = 0
            for categoryFilter in categoryFilters {
                let action: UIAction
                let handler: UIActionHandler = { [weak self] action in
                    self?.viewModel.selectedCategoryFilter = categoryFilter
                }
                switch categoryFilter {
                case .all:
                    action = UIAction(title: "All", handler: handler)
                case .value(let value):
                    action = UIAction(title: String(value), handler: handler)
                }
                self?.filterSegmentedControl.insertSegment(action: action, at: segment, animated: false)
                if categoryFilter == self?.viewModel.selectedCategoryFilter {
                    self?.filterSegmentedControl.selectedSegmentIndex = segment
                }
                segment += 1
            }
        }.store(in: &cancellables)
    }
    
    private func setupTotalValuesSubscription() {
        viewModel.$totalValues.sink { [weak self] totalValues in
            self?.updateTotalValues(totalValues)
        }.store(in: &cancellables)
    }
    
    private func setupErrorSubscription() {
        viewModel.$error.sink { [weak self] error in
            guard let self else { return }
            guard let error else {
                self.errorViewController.remove()
                return
            }
            self.add(self.errorViewController)
            self.errorViewController.setup(text: error.localizedDescription) {
                self.errorViewController.remove()
                self.initialLoad()
            }
            
        }.store(in: &cancellables)
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupFilterSegmentedControl() {
        filterSegmentedControl.backgroundColor = .white
        view.addSubview(filterSegmentedControl)
        filterSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
    
    private func setupBottomTotalView() {
        let bottomTotalStackView = UIStackView()
        bottomTotalStackView.axis = .horizontal
        bottomTotalStackView.distribution = .equalSpacing
        
        let totalLabel = UILabel()
        totalLabel.text = "Total"
        totalLabel.font = .preferredFont(forTextStyle: .body)
        bottomTotalStackView.addArrangedSubview(totalLabel)
        
        totalValuesStackView = UIStackView()
        totalValuesStackView!.axis = .vertical
        bottomTotalStackView.addArrangedSubview(totalValuesStackView!)
        
        let backgroundView = UIView()
        view.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.backgroundColor = .white
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        backgroundView.addSubview(bottomTotalStackView)
        bottomTotalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomTotalStackView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            bottomTotalStackView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
            bottomTotalStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            bottomTotalStackView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 16)
        ])
    }
    
    private func updateTotalValues(_ totalValues: [String]) {
        guard let totalValuesStackView else { return }
        totalValuesStackView.arrangedSubviews.forEach { subView in
            totalValuesStackView.removeArrangedSubview(subView)
            subView.removeFromSuperview()
        }
        for value in totalValues {
            let valueLabel = UILabel()
            valueLabel.text = value
            valueLabel.font = .preferredFont(forTextStyle: .body)
            totalValuesStackView.addArrangedSubview(valueLabel)
        }
    }
    
    private func setupRefreshControl() {
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(reload), for: .valueChanged)
    }
    
    private func initialLoad() {
        refreshControl.beginRefreshing()
        refreshControl.sendActions(for: .valueChanged)
        let contentOffset = CGPoint(x: 0, y: collectionView.contentOffset.y - refreshControl.frame.height)
        collectionView.setContentOffset(contentOffset, animated: true)
        load()
    }
    
    private func load() {
        guard loadingTask == nil else {
            return
        }
        loadingTask = Task {
            await viewModel.load()
            refreshControl.endRefreshing()
            loadingTask = nil
        }
    }
    
    @objc private func reload() {
        load()
    }
}

private extension TransactionsViewController {
    func makeCollectionView() -> UICollectionView {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return UICollectionView(frame: .null, collectionViewLayout: layout)
    }
    
    func makeCellRegistration() -> UICollectionView.CellRegistration<TransactionListCell, TransactionListItemViewModel> {
        UICollectionView.CellRegistration { cell, indexPath, viewModel in
            cell.viewModel = viewModel
            cell.accessories = [.disclosureIndicator()]
        }
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Transaction> {
        let cellRegistration = makeCellRegistration()
        
        return UICollectionViewDiffableDataSource<Section, Transaction>(
            collectionView: collectionView,
            cellProvider: { view, indexPath, transaction in
                view.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: TransactionListItemViewModel(transaction: transaction)
                )
            }
        )
    }
    
    func updateList(transactions: [Transaction]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Transaction>()
        snapshot.appendSections([.main])
        snapshot.appendItems(transactions, toSection: .main)
        dataSource.apply(snapshot)
    }
}

extension TransactionsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let transaction = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        let detailsViewController = TransactionDetailsViewController(transaction: transaction)
        self.navigationController?.show(detailsViewController, sender: self)
    }
}

extension TransactionsViewController {
    enum Section: CaseIterable {
        case main
    }
}

