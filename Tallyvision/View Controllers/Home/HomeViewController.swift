//
//  HomeViewController.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 23. 10. 2024..
//

import UIKit
import AlertKit

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    var todayShows = [Show]()
    var recentShows = [Show]()
    var upcomingShows = [Show]()
   
    private var selectedShow: Show?
    
    var showService: ShowService!
    
    //MARK: - UIComponents
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .appColor
        
        collectionView.register(ShowCardsCell.self, forCellWithReuseIdentifier: ShowCardsCell.identifier)
        collectionView.register(ShowCell.self, forCellWithReuseIdentifier: ShowCell.identifier)
        collectionView.register(SectionTitleReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionTitleReusableView.identifier)
        
        return collectionView.forAutoLayout().forAutoLayout()
    }()
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupServices()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupUI() {
        view.backgroundColor = .appColor
        configureCollectionView()
        configureCompositionalLayout()
    }
    
    

    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.pin(to: view)
    }
    
    private func configureCompositionalLayout() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            switch sectionIndex {
            case 0: return AppLayouts.shared.showCardsSection()
            default: return AppLayouts.shared.posterSection()
            }
        }
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func setupServices() {
        showService = ShowService(httpClient: TVMazeClient())
    }
   
    // MARK: UI Update
    
    private func updateUI() {
        Task {
            await updateTodayShows()
            await updateRecentShows()
            await updateUpcomingShows()
            collectionView.reloadData()
        }
    }
    
    private func updateTodayShows() async {
        do {
            todayShows = try await showService.getTodaysShows()
        } catch {
            log.error(error)
        }
    }
    
    private func updateRecentShows() async {
        do {
            recentShows = try await showService.getRecentShows()
        } catch {
            log.error(error)
        }
    }
    
    private func updateUpcomingShows() async {
        do {
            upcomingShows = try await showService.getUpcomingShows()
        } catch {
            log.error(error)
        }
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return todayShows.count
        case 1: return recentShows.count
        case 2: return upcomingShows.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowCell.identifier, for: indexPath)
                as? ShowCell else {
            log.error("Unable deque TVShowCell")
            return UICollectionViewCell()
        }
        var shows: [Show]
        switch indexPath.section {
        case 0: shows = todayShows
        case 1: shows = recentShows
        case 2: shows = upcomingShows
        default: fatalError("Invalid section")
        }
        guard let image = shows[indexPath.row].image else { return cell }
        guard let imageUrl = indexPath.section == 0 ? image.original : image.medium else { return cell }
        cell.configure(withImageURL: imageUrl)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionTitleReusableView.identifier, for: indexPath)
                as? SectionTitleReusableView else { return UICollectionReusableView() }
        
        switch indexPath.section {
        case 0: header.configure(title: "Today, ", date: Date())
        case 1: header.configure(title: "Just released", date: nil)
        case 2: header.configure(title: "Coming soon")
        default: break
        }
            
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0: selectedShow = todayShows[indexPath.row]
        case 1: selectedShow = recentShows[indexPath.row]
        case 2: selectedShow = upcomingShows[indexPath.row]
        default: break
        }
        
        guard let selectedShow = selectedShow else { return }
        
        navigateToDetails(for: selectedShow)
        
    }
    
}






