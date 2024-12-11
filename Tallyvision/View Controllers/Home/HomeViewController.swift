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
    
    var scheduleService: ScheduleService!
    
    //MARK: - UIComponents
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .screenColor
        
        collectionView.register(ShowCardsCell.self, forCellWithReuseIdentifier: ShowCardsCell.identifier)
        collectionView.register(ShowCell.self, forCellWithReuseIdentifier: ShowCell.identifier)
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.identifier)
        
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
        view.backgroundColor = .screenColor
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
            default: return AppLayouts.shared.showRecommendationsSection()
            }
        }
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func setupServices() {
        scheduleService = ScheduleService(httpClient: TVMazeClient())
    }
    
    // MARK: - Testing
   
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
            todayShows = try await scheduleService.getTodaysShows()
        } catch {
            log.error(error)
        }
    }
    
    private func updateRecentShows() async {
        do {
            recentShows = try await scheduleService.getRecentShows()
        } catch {
            log.error(error)
        }
    }
    
    private func updateUpcomingShows() async {
        do {
            upcomingShows = try await scheduleService.getUpcomingShows()
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
        case 0: return 1
        case 1: return recentShows.count
        case 2: return upcomingShows.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowCardsCell.identifier, for: indexPath)
                    as? ShowCardsCell else {
                log.error("Unable deque ShowCardCell")
                return UICollectionViewCell()
            }
            cell.configure(withShows: todayShows)
            return cell
            
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowCell.identifier, for: indexPath)
                    as? ShowCell else {
                log.error("Unable deque TVShowCell")
                return UICollectionViewCell()
            }
            let shows = indexPath.section == 1 ? recentShows : upcomingShows
            guard let imageUrl = shows[indexPath.row].image?.medium else { return cell }
            cell.configure(withImageURL: imageUrl)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.identifier, for: indexPath)
                as? SectionHeaderView else { return UICollectionReusableView() }
        
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
        case 1: selectedShow = recentShows[indexPath.row]
        case 2: selectedShow = upcomingShows[indexPath.row]
        default: break
        }
        
        guard let selectedShow = selectedShow else { return }
        
        presentDetails(for: selectedShow)
        
    }
    
    private func presentDetails(for show: Show) {
        let showDetailsVC = ShowDetailsViewController()
        showDetailsVC.hidesBottomBarWhenPushed = true
        showDetailsVC.show = show
        navigationController?.pushViewController(showDetailsVC, animated: true)
    }
    
}




