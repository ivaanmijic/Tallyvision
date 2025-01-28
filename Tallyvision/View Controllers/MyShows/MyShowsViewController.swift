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
    
    var nextToWatchItems = [Int64: Episode]() {
        didSet {
            Task {
                await categorizeEpisodes()
                collectionView.reloadData()
            }
        }
    }
    
    private var notStartedEpisodes: [EpisodeWithShowTitle] = []
    private var startedEpisodes: [EpisodeWithShowTitle] = []
    private var upcomingEpisodes: [EpisodeWithShowTitle] = []
    var showTrackers: [ShowTracker]!
    
    let showRepository = ShowRepository()
    let episodeRepository = EpisodeRepository()
    let showTrackerRepository = ShowTrackerRepository()
    
    // MARK: - UI Components
    
    lazy var titleLabel: UILabel = {
        return UILabel.appLabel(withText: "MY SHOWS").forAutoLayout()
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .appColor
        
        collectionView.register(ShowCell.self, forCellWithReuseIdentifier: ShowCell.identifier)
        collectionView.register(EpisodeCollectionViewCell.self, forCellWithReuseIdentifier: EpisodeCollectionViewCell.identifier)
        
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
        setupDataSources()
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
            case 0: return AppLayouts.shared.posterSection()
            default: return AppLayouts.shared.episodesListSection()
            }
        }
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    // MARK: - Data Sources
    
    private func setupDataSources() {
        Task {
            await setupTrackers()
            await setupWatchlistShows()
            await fetchNextEpisodesToWatch()
            collectionView.reloadData()
        }
    }
    
    private func setupTrackers() async {
        do {
            showTrackers = try await showTrackerRepository.fetchAll(withStatus: .watching)
        } catch {
            log.error("Failed to setup Show Trackers:\n\(error)")
        }
    }
    
    private func setupWatchlistShows() async {
        do {
            let watchlistedShowIDs = showTrackers
                .filter { $0.isWatchlisted }
                .map { $0.showID }
            watchlistShows = try await showRepository.fetchAll(withIDs: watchlistedShowIDs)
        } catch {
            log.error("Failed to setup Watchlist:\n\(error)")
        }
    }
    
    private func fetchNextEpisodesToWatch() async {
        for var tracker in showTrackers {
            do {
                if let nextEpisode = try await fetchNextEpisode(for: tracker) {
                    nextToWatchItems[tracker.showID] = nextEpisode
                } else {
                    tracker.markAsCompleted()
                    try await showTrackerRepository.save(tracker)
                }
            } catch {
                log.error("Unable to find next episode for show \(tracker.showID):\n\(error)")
            }
        }
    }
    
    private func fetchNextEpisode(for tracker: ShowTracker) async throws -> Episode? {
        if let lastWatched = tracker.lastWatchedEpisode() {
            if let nextEpisode = try await episodeRepository.fetchEpisode(forSeason: lastWatched.season, number: lastWatched.episode + 1, showId: tracker.showID) {
                return nextEpisode
            }
            if let nextEpisode = try await episodeRepository.fetchEpisode(forSeason: lastWatched.season + 1, number: 1, showId: tracker.showID) {
                return nextEpisode
            }
        } else {
            if let firstEpisode = try await episodeRepository.fetchEpisode(forSeason: 1, number: 1, showId: tracker.showID) {
                return firstEpisode
            }
        }
        return nil
    }
   
    // MARK: - Helpers
    
    private func categorizeEpisodes() async {
        do {
            let showIDs = Array(nextToWatchItems.keys)
            let titles = try await showRepository.fetchShowTitles(forIds: showIDs)
            let episodesWithTitles: [EpisodeWithShowTitle] = nextToWatchItems.compactMap { (showID, episode) in
                guard let showTitle = titles[showID] else {
                    return EpisodeWithShowTitle(episode: episode, showTitle: String())
                }
                return EpisodeWithShowTitle(episode: episode, showTitle: showTitle)
            }

            let today = Date()

            notStartedEpisodes = episodesWithTitles.filter { isNotStarted(episode: $0, today: today) }
            startedEpisodes = episodesWithTitles.filter { isStarted(episode: $0, today: today) }
            upcomingEpisodes = episodesWithTitles.filter { isUpcoming(episode: $0, today: today) }

        } catch {
            log.error("Failed to categorize episodes:\n\(error)")
        }
    }

    private func isNotStarted(episode: EpisodeWithShowTitle, today: Date) -> Bool {
        let isSeason1Episode1 = episode.episode.season == 1 && episode.episode.number == 1
        let isInStartedOrUpcoming = startedEpisodes.contains { $0.episode == episode.episode } ||
                                     upcomingEpisodes.contains { $0.episode == episode.episode }
        return isSeason1Episode1 && !isInStartedOrUpcoming
    }

    private func isStarted(episode: EpisodeWithShowTitle, today: Date) -> Bool {
        guard let airdateString = episode.episode.airdate,
              let airdate = DateFormatter.apiDateFormatter.date(from: airdateString), airdate <= today else {
            return false
        }
        return !notStartedEpisodes.contains { $0.episode == episode.episode } &&
               !upcomingEpisodes.contains { $0.episode == episode.episode }
    }

    private func isUpcoming(episode: EpisodeWithShowTitle, today: Date) -> Bool {
        guard let airdateString = episode.episode.airdate,
              let airdate = DateFormatter.apiDateFormatter.date(from: airdateString), airdate > today else {
            return false
        }
        return !notStartedEpisodes.contains { $0.episode == episode.episode } &&
               !startedEpisodes.contains { $0.episode == episode.episode }
    }
    
}

// MARK: UICollectionViewDelegate, UICollectionViewDataSource

extension MyShowsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return watchlistShows.count
        case 1: return notStartedEpisodes.count
        case 2: return startedEpisodes.count
        case 3: return upcomingEpisodes.count
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowCell.identifier, for: indexPath)
                    as? ShowCell else { break }
            
            let imageURL = watchlistShows[indexPath.row].image?.medium
            cell.configure(withImageURL: imageURL)
            
            return cell
            
        default:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EpisodeCollectionViewCell.identifier, for: indexPath)
                    as? EpisodeCollectionViewCell else { break }
         
            let buttonDisabled = indexPath.section == 3 ? true : false
            var episodeWithShowTitle: EpisodeWithShowTitle
            
            switch indexPath.section {
            case 1: episodeWithShowTitle = notStartedEpisodes[indexPath.row]
            case 2: episodeWithShowTitle = startedEpisodes[indexPath.row]
            case 3: episodeWithShowTitle = upcomingEpisodes[indexPath.row]
            default: return UICollectionViewCell()
            }
            
            cell.configure(episode: episodeWithShowTitle.episode, showTitle: episodeWithShowTitle.showTitle, buttonDisabled: buttonDisabled)
            return cell
            
        }
        return UICollectionViewCell()
    }
        
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let selectedShow = watchlistShows[indexPath.row]
            navigateToDetails(for: selectedShow)
        default: break
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
       
        var title = String()
        switch indexPath.section {
        case 0: title = "Watchlist"
        case 1: title = "Have not Started"
        case 2: title = "Watch next"
        case 3: title = "Upcoming"
        default: break
        }
        
        header.configure(title: title)
        return header
    }
    
}
