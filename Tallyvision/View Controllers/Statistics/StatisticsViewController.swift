//
//  StatisticsViewController.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 23. 10. 2024..
//

import UIKit

class StatisticsViewController: UIViewController {
    // MARK: - Properties
    
    private let titles = [
        "Shows Watching:",
        "Shows Completed:",
        "Episodes Watched:",
        "Episodes to Watch:",
        "Total Time Spent:",
        "Most Watched:"
    ]
    
    private var showsWatching: Int = 0
    private var showsCompleted: Int = 0
    private var episodesWatched: Int = 0
    private var episodesToWatch: Int = 0
    private var totalTimeSpent: String = ""
    private var mostWatchedShow: String?
    
    private var completedShows: [Show] = []
    
    private var showTrackers: [ShowTracker] = []
    private let showTrackerRepository = ShowTrackerRepository()
    private let showRepository = ShowRepository()
    private let episodeRepository = EpisodeRepository()
    
    // MARK: - UI Components
    
    private lazy var titleLabel: UILabel = {
        return UILabel.appLabel(withText: "Stats").forAutoLayout()
    }()
    
    private lazy var gridStackView = GridStackView().forAutoLayout()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ShowCell.self, forCellWithReuseIdentifier: ShowCell.identifier)
        collectionView.register(
            SectionTitleReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionTitleReusableView.identifier
        )
        
        collectionView.layer.cornerRadius = 20
        collectionView.layer.masksToBounds = true
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        return collectionView.forAutoLayout()
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .appColor
        setupNavigationBar()
        configureCollectionView()
        configureCompositionalLayout()
        setupGrid()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStatistics()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
    }
    
        
    private func configureCollectionView() {
        collectionView.backgroundColor = .secondaryAppColor
        collectionView.delegate = self
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate ([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: AppConstants.screenHeight / 3.75)
        ])
    }
   
    private func setupGrid() {
        view.addSubview(gridStackView)
        
        let gridWitdh = AppConstants.screenWidth - 40
        
        NSLayoutConstraint.activate([
            gridStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            gridStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gridStackView.widthAnchor.constraint(equalToConstant: gridWitdh),
            gridStackView.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -40)
        ])
    }

    
    private func configureCompositionalLayout() {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            return AppLayouts.shared.posterSection()
        }
        layout.configuration.scrollDirection = .horizontal
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    private func loadStatistics() {
        Task {
            do {
                try await fetchTrackers()
                try await updateStatistics(trackers: showTrackers)
                try await loadCompletedShows()
                await MainActor.run {
                    configureGridCells()
                    collectionView.reloadData()
                }
            } catch {
                log.error("Failed to laod statistics.")
            }
        }
    }
    
    private func fetchTrackers() async throws {
        showTrackers = try await showTrackerRepository.fetchAll()
    }
    
    func updateStatistics(trackers: [ShowTracker]) async throws {
        showsWatching = trackers.filter { $0.status == .watching }.count
        showsCompleted = trackers.filter { $0.status == .completed }.count
        episodesWatched = trackers.reduce(0) { $0 + $1.watchedEpisodes.count }
        
        try await calculateEpisodesToWatch()
        formatTotalTimeSpent()
        try await fetchMostWatchedShow()
    }
    
    private func calculateEpisodesToWatch() async throws {
        let totalEpisodes = try await episodeRepository.count()
        if let totalEpisodes = totalEpisodes {
            episodesToWatch = totalEpisodes - episodesWatched
        } else {
            episodesToWatch = 0
        }
    }
    
    
    func formatTotalTimeSpent() {
        let totalMinutes = Int(showTrackers.reduce(0) { $0 + $1.totalTimeSpent })
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        let days = hours / 24
        let remainingHours = hours % 24
       
        
        if days > 0 {
            totalTimeSpent += "\(days) day" + (days > 1 ? "s" : "")
        }
        
        if remainingHours > 0 {
            if !totalTimeSpent.isEmpty { totalTimeSpent += " " }
            totalTimeSpent += "\(remainingHours) h"
        }
        
        if minutes > 0 {
            if !totalTimeSpent.isEmpty { totalTimeSpent += " " }
            totalTimeSpent += "\(minutes) min"
        }
        
        if totalTimeSpent.isEmpty {
            totalTimeSpent = "0 min"
        }
    }
    
    private func fetchMostWatchedShow() async throws {
        if let mostWatched = showTrackers.max(by: { $0.watchedEpisodes.count < $1.watchedEpisodes.count }),
           let show = try await showRepository.fetchOne(withID: mostWatched.showID) {
            mostWatchedShow = show.title
        }
    }
    
    private func configureGridCells() {
        let subtitles = [
            String(describing: showsWatching),
            String(describing: showsCompleted),
            String(describing: episodesWatched),
            String(describing: episodesToWatch),
            String(describing: totalTimeSpent),
            mostWatchedShow ?? "No shows watched yet"
        ]
        
        for i in 0..<6 {
            gridStackView.configureCell(at: i, title: titles[i], subtitle: subtitles[i])
        }
    }
    
    private func loadCompletedShows() async throws {
        let completedShowIDs = showTrackers.filter({ $0.status == .completed })
            .map { $0.showID }
        completedShows = try await showRepository.fetchAll(withIDs: completedShowIDs)
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension StatisticsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return completedShows.isEmpty ? 0 : completedShows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowCell.identifier, for: indexPath)
                as? ShowCell else {
            return UICollectionViewCell()
        }
        
        if let image = completedShows[indexPath.row].image,
           let imageURL = image.medium {
            cell.configure(withImageURL: imageURL)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader,
           let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionTitleReusableView.identifier,
            for: indexPath
           ) as? SectionTitleReusableView {
            header.configure(title: "Completed Shows")
            return header
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            navigateToDetails(for: completedShows[indexPath.row])
        }
    }
    
}

extension StatisticsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0
    }
    
}
