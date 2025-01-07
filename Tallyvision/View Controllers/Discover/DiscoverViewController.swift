//
//  DiscoverViewController.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 23. 10. 2024..
//

import UIKit
import Combine

class DiscoverViewController: UIViewController {
    
    // MARK: - Properties
    private var shows: [Show] = []
    
    private var cancellables = Set<AnyCancellable>()
    
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
        collectionView.backgroundColor = .red
       
        return collectionView.forAutoLayout()
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ShowTableViewCell.self, forCellReuseIdentifier: ShowTableViewCell.identifier)
        tableView.backgroundColor = .blue
        return tableView.forAutoLayout()
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupSearchController()
        setupCollectionView()
        setupTableView()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
    }
   
    private func setupUI() {
        view.backgroundColor = .appColor
        view.addSubview(collectionView)
        view.addSubview(tableView)
        tableView.isHidden = true
        setupConstraints()
    }
    
    private func setupConstraints() {
        collectionView.pin(to: view)
        tableView.pin(to: view)
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
    
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource

extension DiscoverViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowCell.identifier, for: indexPath)
                as? ShowCell else {
            return UICollectionViewCell()
        }
        return cell
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension DiscoverViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ShowTableViewCell.identifier, for: indexPath)
                as? ShowTableViewCell else {
            return UITableViewCell()
        }
        return cell
    }
}

// MARK: - UISearchBarDelegate

extension DiscoverViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            tableView.isHidden = true
            collectionView.isHidden = false
        } else {
            tableView.isHidden = false
            collectionView.isHidden = true
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.isHidden = true
        collectionView.isHidden = false
        tableView.reloadData()
    }
    
}
