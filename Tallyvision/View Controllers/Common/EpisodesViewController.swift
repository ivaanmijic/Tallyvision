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
    
    private var show: Show
    private var seasons: [Season]
    private var seasonEpisodes: [Int64 : [Episode]] = [:]
    private var selectedSeason: Season {
        didSet { fetchEpisodesForSelectedSeason() }
    }
    
    // MARK: - Initializers
    
    init(seasons: [Season], show: Show) {
        self.show = show
        self.seasons = seasons
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
        setupUI()
        setupServices()
        fetchEpisodesForSelectedSeason()
    }
    
    private func setupNavigationBar() {
        navigationController?.configureNavigationBar(rightButton: dismissButton, target: self, isTrancluent: false)
        navigationController?.navigationBar.backgroundColor = .appColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
    }
    
    private func setupUI() {
        view.backgroundColor = .blue
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
        
        cell.delegate = self
        cell.configure(episode: episodes[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SeasonSelectionView.identifier)
                as? SeasonSelectionView else { return UITableViewHeaderFooterView() }
        
        let seenEpisdoesCount = seasonEpisodes[selectedSeason.number]?.filter { $0.hasBeenSeen }.count ?? 0
        
        header.delegate = self
        header.configure(seasons: seasons, selectedSeason: selectedSeason, countOfSeen: seenEpisdoesCount)
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
                try await updateSeenStatusForSelectedSeason()
                fetchEpisodesForSelectedSeason()
            } catch {
                log.error("Error updating seen status for \(show.showId), season \(selectedSeason.number)")
            }
        }
    }
    
    func episodeSeenStatusChanged(for episode: Episode) {
        Task {
            log.debug("Attempting to update seen status for episode \(episode.id)")
            var updatedEpisode = episode
            updatedEpisode.showId = show.showId
            updatedEpisode.hasBeenSeen = true
            
            do {
                try await updateSeenStatusForEpisode(updatedEpisode)
                log.debug("Episode \(updatedEpisode.id) updated succesfully")
            } catch {
                await handleUpdateFailure(for: updatedEpisode, error: error)
            }
            fetchEpisodesForSelectedSeason()
        }
    }
    
    private func updateSeenStatusForSelectedSeason() async throws {
        do {
            log.debug("Attempting to update seen status \(show.showId), season \(selectedSeason.number)")
            let episodes = try await getEpisodes(forSeason: selectedSeason.number)
            try await markEpisodesAsWatched(episodes)
        } catch {
            try await ensureShowExists()
            try await ensureSeasonsExist()
            let episodes = try await getEpisodes(forSeason: selectedSeason.number)
            try await markEpisodesAsWatched(episodes)
        }
    }
    
    private func getEpisodes(forSeason seasonNumber: Int64) async throws -> [Episode] {
        return try await episodeRepository.fetchEpisodes(forSeason: seasonNumber, show: show.showId)
    }
    
    private func markEpisodesAsWatched(_ episodes: [Episode]) async throws {
        try await episodeRepository.update(episodes: episodes, showId: show.showId)
    }
    
    private func handleUpdateFailure(for episode: Episode, error: Error) async {
        do {
            try await ensureShowExists()
            try await ensureSeasonsExist()
            try await updateSeenStatusForEpisode(episode)
            log.debug("Episode \(episode.id) updated succesfully")
        } catch {
            log.error("Failed to update seen status for episode \(episode.id):\n \(error)")
        }
    }
    
    private func updateSeenStatusForEpisode(_ episode: Episode) async throws {
        try await episodeRepository.update(episode: episode)
    }
    
    private func ensureShowExists() async throws {
        if !(try await showRepository.exists(showId: show.showId)) {
            try await showRepository.create(show: show)
        }
    }
    
    private func ensureSeasonsExist() async throws {
        log.info(seasons.count)
        for season in self.seasons {
            try await ensureEpisodesExist(for: season)
        }
    }
    
    private func ensureEpisodesExist(for season: Season) async throws {
        let episodes = try await episodeService.fetchEpisodes(forSeason: season.id)
        try await episodeRepository.insert(episodes: episodes, showId: show.showId)
    }
}
    
