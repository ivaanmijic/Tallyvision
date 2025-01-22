//
//  WatchlistViewController.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 23. 10. 2024..
//

import UIKit

class MyShowsViewController: UIViewController {
    // MARK: - Properties
    
    var watchlistShows = [Show]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    let showRepository = ShowRepository()
    
    // MARK: - UI Components
    
    lazy var titleLabel: UILabel = {
        return UILabel.appLabel(withText: "MY SHOWS").forAutoLayout()
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .appColor
        
        collectionView.register(ShowCell.self, forCellWithReuseIdentifier: ShowCell.identifier)
        
        collectionView.register(SectionTitleReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionTitleReusableView.identifier)
        
        return collectionView.forAutoLayout()
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
    }
   
    private func setupUI() {
        view.backgroundColor = .appColor
        configureCollectionView()
        configureCompositionalLayout()
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.pin(to: view)
    }
    
    private func configureCompositionalLayout() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            switch sectionIndex {
            default: return AppLayouts.shared.posterSection()
            }
        }
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    // MARK: - Data loading
    private func loadData() {
        Task {
            do {
                watchlistShows = try await showRepository.fetchListedShows()
            } catch {
                log.error("Error reading listedShows from database:\n\(error)")
            }
        }
    }

}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource

extension MyShowsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return watchlistShows.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowCell.identifier, for: indexPath)
                    as? ShowCell else { return UICollectionViewCell()}
            
            let imageURL = watchlistShows[indexPath.row].image?.medium
            cell.configure(withImageURL: imageURL)
            
            return cell
            
        default: return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        default:
            let selectedShow = watchlistShows[indexPath.row]
            navigateToDetails(for: selectedShow)
            
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionTitleReusableView.identifier,
                for: indexPath
              ) as? SectionTitleReusableView else {
            return UICollectionReusableView()
        }
        
        switch indexPath.section {
        default: header.configure(title: "Watchlist")
        }
        
        return header
    }
    
}
