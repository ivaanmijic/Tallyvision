//
//  ShowDetailsViewController.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 3. 12. 2024..
//

import UIKit
import AlertKit

class ShowViewController: UIViewController, UIGestureRecognizerDelegate {
    // MARK: - Properties
    
    var show: Show
    var showCast = [ShowCast]()
    var cast = [Person]()
    var seasons = [Season]()
    var showTracker: ShowTracker!
    
    var castService: CastService!
    var seasonService: SeasonService!
    let showRepository = ShowRepository()
    let episodeRepository = EpisodeRepository()
    let showTrackerRepository = ShowTrackerRepository()
    
    var previousOffset: CGFloat = 0
    var isAddButtonVisible = false
    
    // MARK: - Constructors
    init(show: Show) {
        self.show = show
        super.init(nibName: nil, bundle: nil)
        log.info("Loaded show with ID: \(show.showId)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    
    lazy var backButton: TransparentButton = {
        let button = TransparentButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return button
    }()
    
    lazy var backgroundImage = UIImageView().forAutoLayout()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "mask")
        collectionView.register(CastCell.self, forCellWithReuseIdentifier: CastCell.identifier)
        
        collectionView.register(
            ShowOveriewView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: ShowOveriewView.reuseIdentifier
        )
        
        collectionView.register(
            SectionTitleReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionTitleReusableView.identifier
        )
        
        return collectionView.forAutoLayout()
    }()
    
    lazy var watchlistButton: AppButton = {
        let button = AppButton(
            color: .baseYellow, 
            image: UIImage(named: "bookmark")!,
            frame: .zero)
        button.alpha = 0.0
        button.titleLabel?.textColor = .black
        button.addTarget(self, action: #selector(toggleWatchlistStatus), for: .touchUpInside)
        return button.forAutoLayout()
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupServices()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupShowTracker()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        hideAddButton()
    }
    
    private func setupNavigationBar() {
        navigationController?.configureNavigationBar(leftButton: backButton, target: self)
    }
   
    private func setupShowTracker() {
        Task {
            do {
                showTracker = try await showTrackerRepository.fetchShowTracker(for: show.showId)
                watchlistButton.updateButtonAppearance(isListed: showTracker.isWatchlisted)
            } catch {
                showTracker = ShowTracker(showID: show.showId, watchedEpisodes: [], totalTimeSpent: 0, status: .watching, isWatchlisted: false)
                watchlistButton.updateButtonAppearance(isListed: false)
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .appColor
        setupBackgroundImage()
        configureCollectionView()
        configureCompositionalLayout()
        setupWatchlistButton()
    }
    
    private func setupServices() {
        castService = CastService(httpClinet: TVMazeClient())
        seasonService = SeasonService(httpClient: TVMazeClient())
    }
    
    private func setupBackgroundImage() {
        backgroundImage.configure(image: show.image?.original)
        view.addSubview(backgroundImage)
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.heightAnchor.constraint(equalToConstant: AppConstants.screenWidth * AppConstants.posterImageRatio)
        ])
    }
    
    private func setupWatchlistButton() {
        view.addSubview(watchlistButton)
        watchlistButton.configure(title: "Add to Watchlist")
        NSLayoutConstraint.activate([
            watchlistButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 84),
            watchlistButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            watchlistButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            watchlistButton.heightAnchor.constraint(equalToConstant: 50),
            watchlistButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
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
            case 1:
                return AppLayouts.shared.castSection()
                
            default:
                return AppLayouts.shared.metaDataSection()
            }
        }
        layout.register(BackgroundSupplementaryView.self, forDecorationViewOfKind: "backgroundDecoration")
        
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func toggleWatchlistStatus() {
        showTracker.isWatchlisted ? presentAlert() : addShowToWatchlist()
    }
  
    private func addShowToWatchlist() {
        Task {
            do {
                showTracker.addToWatchlist()
                try await showTrackerRepository.save(showTracker)
                try await ensureContentExists()
                setupShowTracker()
            } catch {
                log.error("Error adding show \(show.title) \(show.showId) to wathclist:\n \(error)")
            }
        }
    }
    
    private func ensureContentExists() async throws {
        try await showRepository.insertOrIgnore(show: show)
        let episodeService = EpisodeService(httpClient: TVMazeClient())
        let episodes = try await episodeService.getEpisodes(forShow: show.showId)
        try await episodeRepository.insertOrIgnore(episodes: episodes, showId: show.showId)
    }
    
    private func presentAlert() {
        let title = "Remove from Watchlist?"
        let message = "Are you sure you want to remove \(show.title) from your watchlist?"
        
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { [weak self] _ in
            self?.removeShowFromWatchlist()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(removeAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func removeShowFromWatchlist() {
        Task {
            do {
                showTracker.removeFromWatchlist()
                try await showTrackerRepository.save(showTracker)
                watchlistButton.updateButtonAppearance(isListed: showTracker.isWatchlisted)
            } catch {
                log.error("Error deleteing show \(show.showId) from database:\n \(error)")
            }
        }
    }
    
    
    // MARK: - UI Update
    
    private func updateUI() {
        Task {
            await updateSeasons()
            await updateCast()
            reloadData()
        }
    }
    
    private func updateCast() async {
        do {
            (cast, showCast) = try await castService.getCastForShow(withId: show.showId)
        } catch {
            displayError(error)
        }
    }
    
    private func updateSeasons() async {
        do {
            seasons = try await seasonService.getSeasonsFowShow(withId: show.showId)
        } catch {
            log.error("Error fetching seasons\n: \(error)")
            displayError(error)
        }
    }
    
    private func reloadData() {
        collectionView.reloadData()
    }
    
    private func displayError(_ error: Error) {
        if let error = error as? NetworkError {
            AlertKitAPI.present(
                title: error.localizedDescription,
                icon: .error,
                style: .iOS17AppleMusic
            )
        }
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension ShowViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 1:
            log.info(showCast.count)
            return showCast.count
        default: return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
           
            
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastCell.identifier, for: indexPath) as? CastCell else {
                log.error("Unable to dequeue \(CastCell.identifier)")
                return UICollectionViewCell()
            }
            let actor = cast[indexPath.row]
            let characterName = showCast[indexPath.row].characterName
            cell.configure(name: actor.name, characterName: characterName, imageURL: actor.image?.medium)
            return cell
            
        default:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "mask", for: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
            
        case UICollectionView.elementKindSectionFooter where indexPath.section == 0:
            guard let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ShowOveriewView.reuseIdentifier,
                for: indexPath
            ) as? ShowOveriewView else { break }
            footer.delegate = self
            footer.configure(withShow: show, seasons: seasons)
            return footer
            
        case UICollectionView.elementKindSectionHeader where indexPath.section == 1:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionTitleReusableView.identifier,
                for: indexPath
            ) as? SectionTitleReusableView else { break }
            if !cast.isEmpty {
                header.configure(title: "Cast")
            }
            return header
            
        default: break
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        let castVC = CastViewController(actor: cast[indexPath.row])
        castVC.modalPresentationStyle = .pageSheet
        castVC.delegate = self
        
        if let sheet = castVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(castVC, animated: true)
        
    }
    
}

// CastViewControllerDelegate

extension ShowViewController: CastViewControllerDelegate, ShowOveriewDelegate {
    
    func presentEpisodes() {
        let episodesVC = EpisodesViewController(seasons: seasons, show: show, tracker: showTracker)
        let episodesNavigationVC = UINavigationController(rootViewController: episodesVC)
        present(episodesNavigationVC, animated: true)
    }
   
    func pushShowViewController(for show: Show) {
        navigateToDetails(for: show)
    }
    
}

// MARK: - UIScrollViewDelegate

extension ShowViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.bounds.height
        
        if contentHeight < 100 {
            return
        }
        
        if offsetY + scrollViewHeight >= contentHeight - 50 {
            if !isAddButtonVisible {
                showAddButton()
            }
        } else {
            if isAddButtonVisible {
                hideAddButton()
            }
        }
    }
    
    func showAddButton() {
        isAddButtonVisible = true
        UIView.animate(withDuration: 0.3) {
            self.watchlistButton.alpha = 1.0
            self.watchlistButton.transform = CGAffineTransform(translationX: 0, y: -100)
        }
    }
    
    func hideAddButton() {
        isAddButtonVisible = false
        UIView.animate(withDuration: 0.3) {
            self.watchlistButton.alpha = 0.0
            self.watchlistButton.transform = .identity
        }
    }
    
}
