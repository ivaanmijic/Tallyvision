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
    private var recentShows: [Show] = []
    private var shows:[Show] = []
        
    private var searchService: SearchService!
    
    private var cancellables = Set<AnyCancellable>()
   
    private var shouldHideHeader = false
    
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
        let cellWidth = AppConstants.screenWidth/3 - 10
        let cellHeight = cellWidth * AppConstants.posterImageRatio
       
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ShowCell.self, forCellWithReuseIdentifier: ShowCell.identifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.scrollsToTop = true
        return collectionView.forAutoLayout()
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
        let animation = LottieAnimationView(name: "search-animation")
        animation.frame = view.bounds
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .loop
        animation.animationSpeed = 1
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
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
        navigationController?.hidesBarsOnSwipe = true
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
        animationView.pin(to: view)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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
        
        navigationController?.navigationBar.barTintColor = .appColor
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
        searchService = SearchService(httpClient: TVMazeClient())
    }
    
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource

extension DiscoverViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowCell.identifier, for: indexPath)
                as? ShowCell else {
            return UICollectionViewCell()
        }
        cell.backgroundColor = .secondaryAppColor.withAlphaComponent(0.5)
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
                    self.shows = try await self.searchService.searchShows(forQuery: query)
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





