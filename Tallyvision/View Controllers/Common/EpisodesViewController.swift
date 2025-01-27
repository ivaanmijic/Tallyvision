//
//  EpisodesViewController.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 11. 1. 2025..
//

import UIKit

class EpisodesViewController: UIViewController {
    // MARK: - Properties
    
    private var episodeService: EpisodeService!
    private var seasonServcie: SeasonService!
    private var showService: ShowService!
    private let episodeRepository = EpisodeRepository()
    private let showRepository = ShowRepository()
    private let showTrackerRepository = ShowTrackerRepository()
    
    private var show: Show
    private var showTracker: ShowTracker
    private var seasons: [Season]
    private var seasonEpisodes: [Int64 : [Episode]] = [:]
    private var selectedSeason: Season {
        didSet { fetchEpisodesForSelectedSeason() }
    }
    
    // MARK: - Initializers
    
    init(seasons: [Season], show: Show, tracker: ShowTracker) {
        self.show = show
        self.seasons = seasons
        self.showTracker = tracker
        self.selectedSeason = seasons[0]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    
    lazy var titleLabel = UILabel.appLabel(withText: "Episodes", fontSize: 32).forAutoLayout()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont(name: "RedHatDisplay-SemiBold", size: 18)
        button.setTitleColor(.baseYellow, for: .normal)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        return button.forAutoLayout()
    }()
   
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .appColor
        tableView.separatorStyle = .none
        tableView.register(EpisodeTableViewCell.self, forCellReuseIdentifier: EpisodeTableViewCell.identifier)
        tableView.register(SeasonSelectionView.self, forHeaderFooterViewReuseIdentifier: SeasonSelectionView.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView.forAutoLayout()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        updateShowTracker()
        setupUI()
        setupServices()
        fetchEpisodesForSelectedSeason()
    }
    
    
    
    private func setupNavigationBar() {
        navigationController?.configureNavigationBar(rightButton: dismissButton, target: self, isTrancluent: false)
        navigationController?.navigationBar.backgroundColor = .appColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
    }
    
    private func updateShowTracker() {
        Task {
            showTracker = try await showTrackerRepository.fetchShowTracker(for: show.showId)
            await MainActor.run { tableView.reloadData() }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .appColor
        view.addSubview(tableView)
        tableView.pin(to: view)
    }
    
    private func setupServices() {
        episodeService = EpisodeService(httpClient: TVMazeClient())
        seasonServcie = SeasonService(httpClient: TVMazeClient())
        showService = ShowService(httpClient: TVMazeClient())
    }
   
    // MARK: - Data Handling
    
    private func fetchEpisodesForSelectedSeason() {
        Task {
            do {
                let episodes = try await fetchEpisodes(for: selectedSeason)
                seasonEpisodes[selectedSeason.number] = episodes
                tableView.reloadData()
            } catch {
                log.error("Failed to fetch episodes for season \(selectedSeason.number):\n \(error)")
            }
        }
    }
    
    private func fetchEpisodes(for season: Season) async throws -> [Episode] {
        let cachedEpisodes = try await episodeRepository.fetchEpisodes(forSeason: season.number, show: show.showId)
        if !cachedEpisodes.isEmpty {
            return cachedEpisodes
        }
        return try await episodeService.fetchEpisodes(forSeason: season.id)
    }

    // MARK: - Actions
    
    @objc private func dismissController() {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension EpisodesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let episodes = seasonEpisodes[selectedSeason.number] else { return 0 }
        return Int(episodes.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeTableViewCell.identifier) as? EpisodeTableViewCell,
              let episodes = seasonEpisodes[selectedSeason.number] else { return UITableViewCell() }
    
        let episode = episodes[indexPath.row]
        let status = showTracker.hasSeenEpisode(inSeason: selectedSeason.number, episode: episode.number ?? 0)
        cell.delegate = self
        cell.configure(episode: episode, status: status)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SeasonSelectionView.identifier)
                as? SeasonSelectionView else { return UITableViewHeaderFooterView() }
        
        let episodesInSelectedSeason = seasonEpisodes[selectedSeason.number] ?? []
        
        let watchedEpisodesCount = episodesInSelectedSeason.filter { episode in
            showTracker.hasSeenEpisode(inSeason: selectedSeason.number, episode: episode.number ?? 0)
        }.count
        
        header.delegate = self
        header.configure(seasons: seasons, selectedSeason: selectedSeason, countOfSeen: watchedEpisodesCount)
        return header
    }
}

// MARK: SeasonSelectionViewDelegate, EpisodeTableViewCellDelegate

extension EpisodesViewController: SeasonSelectionViewDelegate, EpisodeTableViewCellDelegate {
    
    func seasonSelected(withNumber number: Int64) {
        selectedSeason = seasons.first { $0.number == number } ?? selectedSeason
    }
    
    func seasonMarkedAsWatched() {
        Task {
            do {
                try await updateAndMarkSeasonAsWatched()
                await MainActor.run { tableView.reloadData() }
            } catch {
                log.error("Error updating seen status for \(show.showId), season \(selectedSeason.number): \(error)")
            }
        }
    }
    
    func episodeSeenStatusChanged(for episode: Episode) {
        Task {
            do {
                try await updateAndMarkEpisodeAsWatched(episode)
                await MainActor.run { tableView.reloadData() }
            } catch {
                log.error("Failed to update seen status for episode \(episode.id): \(error)")
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func updateAndMarkSeasonAsWatched() async throws {
        await updateShowTracker()
        try await ensureContentExists()
        log.info("Marking all episodes as watched for season \(selectedSeason.number)")
        
        let episodes = try await getEpisodes(forSeason: selectedSeason.number)
        for episode in episodes {
            guard let episodeNumber = episode.number,
                  !showTracker.hasSeenEpisode(inSeason: selectedSeason.number, episode: episodeNumber) else { continue }
            
            showTracker.markEpisodeAsWatched(
                inSeason: selectedSeason.number,
                episode: episodeNumber,
                runtime: episode.runtime ?? 0
            )
        }
        try await showTrackerRepository.save(showTracker)
    }
    
    private func updateAndMarkEpisodeAsWatched(_ episode: Episode) async throws {
        await updateShowTracker()
        try await ensureContentExists()
        
        guard let episodeNumber = episode.number,
              !showTracker.hasSeenEpisode(inSeason: selectedSeason.number, episode: episodeNumber) else { return }
        
        showTracker.markEpisodeAsWatched(
            inSeason: selectedSeason.number,
            episode: episodeNumber,
            runtime: episode.runtime ?? 0
        )
        try await showTrackerRepository.save(showTracker)
    }
    
    private func updateShowTracker() async {
        do {
            showTracker = try await showTrackerRepository.fetchShowTracker(for: show.showId)
        } catch {
            log.error("Error updating Show Tracker for \(show.showId): \(error)")
        }
    }
    
    private func ensureContentExists() async throws {
        try await showRepository.insertOrIgnore(show: show)
        let episodes = try await fetchEpisodesFromService()
        try await episodeRepository.insertOrIgnore(episodes: episodes, showId: show.showId)
    }
    
    private func fetchEpisodesFromService() async throws -> [Episode] {
        let episodeService = EpisodeService(httpClient: TVMazeClient())
        return try await episodeService.getEpisodes(forShow: show.showId)
    }
    
    private func getEpisodes(forSeason seasonNumber: Int64) async throws -> [Episode] {
        return try await episodeRepository.fetchEpisodes(forSeason: seasonNumber, show: show.showId)
    }
    
}
    
