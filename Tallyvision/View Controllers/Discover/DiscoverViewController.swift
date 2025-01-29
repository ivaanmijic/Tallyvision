//
//  DiscoverViewController.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 23. 10. 2024..
//

import UIKit
import Combine
import AlertKit
import Lottie

class DiscoverViewController: UIViewController {
    
    // MARK: - Properties
    private var images: [Image] = []
    private var shows:[Show] = []
    private var showService: ShowService!
    private let showRepository = ShowRepository()
    private var cancellables = Set<AnyCancellable>()
    private var shouldHideHeader = false
    
    private let rows = 4
    private let columns = 3
    private let totalCells = 12
    private let cellSpacing: CGFloat = 10
    
    // MARK: - UI Components
    
    lazy var titleLabel: UILabel = {
        return UILabel.appLabel(withText: "DISCOVER").forAutoLayout()
    }()
    
    lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.translatesAutoresizingMaskIntoConstraints = false
        controller.searchBar.placeholder = "Find shows"
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.keyboardType = .default
        controller.searchBar.backgroundColor = .appColor
        return controller
    }()
    
    lazy var collectionView: UICollectionView = {
        let cellWidth = (AppConstants.screenWidth - (CGFloat(columns + 1) * cellSpacing)) / CGFloat(columns)
        let cellHeight = cellWidth * AppConstants.posterImageRatio
        let collectionHeight = cellHeight * CGFloat(rows) + cellSpacing * CGFloat(rows + 1)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = cellSpacing
        layout.minimumInteritemSpacing = cellSpacing
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.register(ShowCell.self, forCellWithReuseIdentifier: ShowCell.identifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        
        collectionView.heightAnchor.constraint(equalToConstant: collectionHeight).isActive = true
        
        return collectionView
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ShowTableViewCell.self, forCellReuseIdentifier: ShowTableViewCell.identifier)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView.forAutoLayout()
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator.forAutoLayout()
    }()
    
    lazy var animationView: LottieAnimationView = {
        let animation = LottieAnimationView(name: "loopanimation")
        animation.frame = view.bounds
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .loop
        animation.animationSpeed = 0.75
        return animation.forAutoLayout()
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupAnimation()
        setupSearchController()
        setupCollectionView()
        setupTableView()
        setupServices()
        loadImages()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
    }
    
    private func setupUI() {
        view.backgroundColor = .appColor
        view.addSubview(collectionView)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(animationView)
        tableView.isHidden = true
        setupConstraints()
    }
    
    private func setupConstraints() {
        collectionView.pin(to: view)
        tableView.pin(to: view)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.35),
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            
        ])
    }
    
    private func setupAnimation() {
        animationView.play()
    }
    
    
    private func setupSearchController() {
        searchController.searchBar.delegate = self
        
        let placeHolderAppearance = UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        placeHolderAppearance.font = UIFont(name: "RedHatDisplay-Regular", size: 16)
        
        let cancelAppearence = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        cancelAppearence.setTitleTextAttributes([.font: UIFont(name: "RedHatDisplay-Regular", size: 16)!], for: .normal)
        cancelAppearence.tintColor = .baseYellow
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupServices() {
        showService = ShowService(httpClient: TVMazeClient())
    }
    
    private func loadImages() {
        Task {
            do {
                self.images = try await showRepository.fetchAllImages()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } catch {
                print("Failed to fetch random shows: \(error.localizedDescription)")
            }
        }
    }
    
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource

extension DiscoverViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowCell.identifier, for: indexPath)
                as? ShowCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(withImageURL: images[indexPath.row].medium, alpha: 0.3)
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension DiscoverViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShowTableViewCell.identifier, for: indexPath)
                as? ShowTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.configure(withShow: shows[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigateToDetails(for: shows[indexPath.row])
    }
    
}

// MARK: - UISearchBarDelegate

extension DiscoverViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        toggleViewVisiblityForSearch(textDidChange: searchText)
        performSearch(withQuery: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideTableView()
        tableView.reloadData()
    }
    
    private func performSearch(withQuery query: String) {
        showLoadingIndicator()
        
        DispatchQueue.main.asyncDeduped(target: self, after: 0.4) { [weak self] in
            guard let self = self else { return }
            Task {
                do {
                    self.shows = try await self.showService.searchShows(forQuery: query)
                    DispatchQueue.main.async {
                        self.updateUI()
                        self.hideLoadingIndicator()
                    }
                } catch {
                    log.error("Error (searching):\n \(error)")
                    AlertKitAPI.present(
                        title: "Error",
                        icon: .error,
                        style: .iOS17AppleMusic,
                        haptic: .error
                    )
                    self.hideLoadingIndicator()
                }
            }
        }
    }
    
    private func updateUI() {
        tableView.reloadData()
    }
    
    private func showLoadingIndicator() {
        if activityIndicator.superview == nil {
            view.addSubview(activityIndicator)
        }
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
}

// MARK: - ViewVisibility

extension DiscoverViewController {
    
    private func toggleViewVisiblityForSearch(textDidChange searchText: String) {
        if searchText.isEmpty {
            hideTableView()
        } else {
            showCollectionView()
        }
    }
    
    private func hideTableView() {
        animateTransition(from: tableView, to: collectionView)
    }
    
    private func showCollectionView() {
        animateTransition(from: collectionView, to: tableView)
    }
    
    private func animateTransition(
        from outgoingView: UIView,
        to incomingView: UIView,
        duration: TimeInterval = 0.8
    ) {
        let shouldShowAnimation = (incomingView == collectionView)
        
        if shouldShowAnimation {
            animationView.isHidden = false
            animationView.play()
        }
        
        incomingView.isHidden = false
        incomingView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        incomingView.alpha = 0
        
        UIView.animate(withDuration: duration, animations: {
            incomingView.transform = .identity
            incomingView.alpha = 1
            outgoingView.alpha = 0
            self.animationView.alpha = shouldShowAnimation ? 1 : 0
        }, completion: { _ in
            outgoingView.isHidden = true
            outgoingView.alpha = 1
            if !shouldShowAnimation {
                self.animationView.stop()
                self.animationView.isHidden = true
            }
        })
        
    }
}





