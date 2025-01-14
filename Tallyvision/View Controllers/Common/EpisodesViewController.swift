//
//  EpisodesViewController.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 11. 1. 2025..
//

import UIKit

class EpisodesViewController: UIViewController {
    // MARK: - Properties
    
    var episodeService: EpisodeService!
    
    var seasons: [Season]
    var seasonEpisodes: [Int64 : [Episode]] = [:]
   
    var selectedSeason: Season {
        didSet {
            print("Test")
            reloadTableView()
        }
    }
    
    // MARK: - Initializers
    init(seasons: [Season]) {
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
        tableView.register(EpisodesTableViewCell.self, forCellReuseIdentifier: EpisodesTableViewCell.identifier)
        tableView.register(SeasonSelectionView.self, forHeaderFooterViewReuseIdentifier: SeasonSelectionView.identifier)
        return tableView.forAutoLayout()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupServices()
        reloadTableView()
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
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupServices() {
        episodeService = EpisodeService(httpClient: TVMazeClient())
    }
    

    // MARK: - Actions
    @objc private func dismissController() {
        dismiss(animated: true)
    }
    
    private func reloadTableView() {
        if seasonEpisodes[selectedSeason.number] == nil {
            updateData()
        } else {
            tableView.reloadData()
        }
    }
   
    private func updateData() {
        Task {
            await updateEpisodes()
            tableView.reloadData()
        }
    }
    
    private func updateEpisodes() async {
        do {
            let episodes = try await episodeService.fetchEpisodesForSeason(withId: selectedSeason.id)
            seasonEpisodes[selectedSeason.number] = episodes
            print("fetched episodes,", episodes)
        } catch {
            log.error("Error occured updating episodes:\n\(error)")
        }
    }
}

extension EpisodesViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let episodes = seasonEpisodes[selectedSeason.number] else { return 0 }
        return Int(episodes.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EpisodesTableViewCell.identifier)
                as? EpisodesTableViewCell,
              let episodes = seasonEpisodes[selectedSeason.number]
        else {
            return UITableViewCell()
        }
        cell.configure(episode: episodes[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SeasonSelectionView.identifier)
                as? SeasonSelectionView else {
            return UITableViewHeaderFooterView()
        }
        header.delegate = self
        header.configure(seasons: seasons, selectedSeason: selectedSeason)
        return header
    }
}

extension EpisodesViewController: SeasonSelectionViewDelegate {
    func selectSeason(withNumber number: Int64) {
        selectedSeason = seasons.first { $0.number == number } ?? selectedSeason
    }
    
    
}
