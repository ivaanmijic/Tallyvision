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
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupSearchController()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
    }
   
    private func setupUI() {
        view.backgroundColor = .appColor
        setupConstraints()
    }
    
    private func setupConstraints() {
        
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
    
}

extension DiscoverViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
     // TODO
    }
}
