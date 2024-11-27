//
//  HomeViewController.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 23. 10. 2024..
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    var shows = [Show]()
    
    //MARK: - UIComponents
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .screenColor
        
        collectionView.register(ShowCardsCell.self, forCellWithReuseIdentifier: ShowCardsCell.identifier)
        collectionView.register(ShowCell.self, forCellWithReuseIdentifier: ShowCell.identifier)
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.identifier)
        
        return collectionView.forAutoLayout()
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await fetchShows()
            await fetchEpisodes()
        }
        setupUI()
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
    
    // MARK: - Testing
   
    private func fetchEpisodes() async {
        do {
            let episodes = try await TVMazeClient.shared.fetchEpisodes()
            for episode in episodes {
                log.info(episode.embeddedShow.show.title)
            }
        } catch {
            log.error("Error fetech today streaming episodes\n\(error)")
        }
    }
    
    private func fetchShows() async {
        do {
            let fetchedShows = try await TVMazeClient.shared.fetchShows()
            let dropedShows = Array(fetchedShows.dropFirst(fetchedShows.count - 7))
            shows = dropedShows
            collectionView.reloadData()
        } catch {
            log.error("Error fetching shows\n\(error)")
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
        case 1: return shows.count
        case 2: return shows.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowCardsCell.identifier, for: indexPath)
                    as? ShowCardsCell else {
                log.error("Unable deque TVShowCell")
                return UICollectionViewCell()
            }
            cell.showCards = ShowCards(shows: shows)
            return cell
            
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowCell.identifier, for: indexPath)
                    as? ShowCell else {
                log.error("Unable deque TVShowCell")
                return UICollectionViewCell()
            }
            guard let imageUrl = shows[indexPath.row].image.medium else { return cell }
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
        case 1: header.configure(title: "Recent shows", date: nil)
        case 2: header.configure(title: "Comming soon")
        default: break
        }
            
        return header
    }
    
}




