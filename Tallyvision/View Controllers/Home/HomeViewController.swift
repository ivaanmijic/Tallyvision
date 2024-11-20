//
//  HomeViewController.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 23. 10. 2024..
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    var tvShowCards: ShowCards?
    var shows = [Show]()
    private var initialCardCenter: CGPoint = .zero
    private var currentShowIndex = 0
    
    //MARK: - UIComponents
   
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .clear
        return view.forAutoLayout()
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view.forAutoLayout()
    }()
    
    lazy var titleLabel: UILabel = .screenTitle(withText: "HOME").forAutoLayout()
    lazy var recommendedShowsLabel: UILabel = .subtitle(withText: "Top shows this week").forAutoLayout()
    lazy var newEpisodesLabel: UILabel = .subtitle(withText: "New in subscriptions").forAutoLayout()
    lazy var recentShowsLabel: UILabel = .subtitle(withText: "Recent aired").forAutoLayout()
    lazy var upcomingShowsLabel: UILabel = .subtitle(withText: "Upcoming shows").forAutoLayout()
    
    lazy var tvShowCardView: TvShowCardView = {
        let view = TvShowCardView()
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        return view.forAutoLayout()
    }()
    
    lazy var dotsIndicator = DotsIndicatorView().forAutoLayout()
    lazy var blurredBackground = BlurredImageView().forAutoLayout()
    
    lazy var upcomingShowsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TvShowCell.self, forCellWithReuseIdentifier: TvShowCell.identifier)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView.forAutoLayout()
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViews()
        setupUI()
        setupPanGesture()
        Task {
            await fetchShows()
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .screenColor
        setupNavigationBar()
        addSubviews()
        configureDotsIndicator()
        setupConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(blurredBackground)
        contentView.addSubview(recommendedShowsLabel)
        contentView.addSubview(tvShowCardView)
        contentView.addSubview(dotsIndicator)
        contentView.addSubview(upcomingShowsLabel)
        contentView.addSubview(upcomingShowsCollectionView)
    }
    
    private func configureDotsIndicator() {
        dotsIndicator.configureDots(count: 5)
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
    }
    
   
    
    private func setupConstraints() {
        
        scrollView.pin(to: view)
        
        let scrollContentGuide = scrollView.contentLayoutGuide
        let scrollFrameGuide = scrollView.frameLayoutGuide
        
        
        NSLayoutConstraint.activate([
            
            contentView.leadingAnchor.constraint(equalTo: scrollFrameGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollFrameGuide.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollContentGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollContentGuide.bottomAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 10000),
            
            recommendedShowsLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            recommendedShowsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            recommendedShowsLabel.heightAnchor.constraint(equalToConstant: 30),
            
            tvShowCardView.topAnchor.constraint(equalTo: recommendedShowsLabel.bottomAnchor, constant: 16),
            tvShowCardView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            tvShowCardView.widthAnchor.constraint(equalToConstant: 272 * 1.1),
            tvShowCardView.heightAnchor.constraint(equalToConstant: 400 * 1.1),
            
            blurredBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -self.topBarHeight),
            blurredBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -60),
            blurredBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 60),
            blurredBackground.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width + 120) * 1000 / 680),
            
            dotsIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dotsIndicator.topAnchor.constraint(equalTo: tvShowCardView.bottomAnchor, constant: 10),
            dotsIndicator.heightAnchor.constraint(equalToConstant: 40),
            
            upcomingShowsLabel.topAnchor.constraint(equalTo: dotsIndicator.bottomAnchor, constant: 24),
            upcomingShowsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            upcomingShowsLabel.heightAnchor.constraint(equalToConstant: 30),
            
            upcomingShowsCollectionView.topAnchor.constraint(equalTo: upcomingShowsLabel.bottomAnchor, constant: 16),
            upcomingShowsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            upcomingShowsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            upcomingShowsCollectionView.heightAnchor.constraint(equalToConstant: 240)
            
        ])
    }
    
    // MARK: - Pan Gesture Setup
    
    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        tvShowCardView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view)
        let velocity = gesture.velocity(in: self.view)
        
        switch gesture.state {
        case .began:
            initialCardCenter = tvShowCardView.center
            log.debug("began")
        case .changed:
            updateCardPositionWithTranslation(translation)
            log.debug("changed")
        case .ended:
            handlePanGestureEnd(translation: translation, velocity: velocity)
            log.debug("ended")
        default:
            break
        }
    }
    
    private func updateCardPositionWithTranslation(_ translation: CGPoint) {
        tvShowCardView.center = CGPoint(x: initialCardCenter.x + translation.x, y: initialCardCenter.y)
        let rotationAngle = translation.x / 2000
        tvShowCardView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        
        let scale = 1 - min(abs(translation.x) / 300, 0.2)
        tvShowCardView.transform = tvShowCardView.transform.scaledBy(x: scale, y: scale)
    }
    
    private func handlePanGestureEnd(translation: CGPoint, velocity: CGPoint) {
        let swipeThreshold: CGFloat = 80
        let velocityThreshold: CGFloat = 400
        
        if abs(translation.x) > swipeThreshold || abs(velocity.x) > velocityThreshold {
            let direction: CGFloat = translation.x > 0 ? 1 : -1
            animateCardSwipe(direction: direction)
        } else { updateCardPosition(reset: true) }
        
    }
   
    // MARK: - Card Animation
    
    private func animateCardSwipe(direction: CGFloat) {
        let offScreenX = direction * self.view.frame.width * 1.5
        UIView.animate(withDuration: 0.3, animations: {
            self.tvShowCardView.center = CGPoint(x: self.tvShowCardView.center.x + offScreenX, y: self.tvShowCardView.center.y)
            self.tvShowCardView.alpha = 0
        }) { [weak self] _ in
            self?.updateShowIndex(forDirection: direction)
            self?.updateRecommendedShow()
            self?.updateCardPosition()
        }
    }
    
    private func updateShowIndex(forDirection direction: CGFloat) {
        if direction > 0 {
            currentShowIndex -= 1
            tvShowCards?.goToNextShow()
        } else {
            currentShowIndex += 1
            tvShowCards?.goToPrevShow()
        }
    }
    
    private func updateCardPosition(reset: Bool = false) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            if reset == true {
                resetCardPosition()
            }
            self.tvShowCardView.alpha = 1
            self.tvShowCardView.transform = CGAffineTransform.identity
        }
    }

    
    private func updateRecommendedShow() {
        guard let currentShow = tvShowCards?.currentShow() else { return }
        tvShowCardView.configure(forShow: currentShow)
        blurredBackground.configure(forShow: currentShow)
        dotsIndicator.highlightDot(atIndex: currentShowIndex)
        resetCardPosition()
    }
    
    private func resetCardPosition() {
        tvShowCardView.center = initialCardCenter
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
   
    
    // MARK: - Testing
    
    private func fetchShows() async {
        do {
            let fetchedShows = try await TVMazeClient.shared.fetchShows()
            let dropedShows = Array(fetchedShows.dropFirst(fetchedShows.count - 5))
            shows = dropedShows
            tvShowCards = ShowCards(shows: dropedShows)
            upcomingShowsCollectionView.reloadData()
        } catch {
            log.error("Error fetching shows\n\(error)")
        }
    }
    
}


// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
   
    private func setupCollectionViews() {
        upcomingShowsCollectionView.delegate = self
        upcomingShowsCollectionView.dataSource = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TvShowCell.identifier, for: indexPath)
                as? TvShowCell else {
            log.fault("Failed to deque TvShowCell in HomeViewController")
            return UICollectionViewCell()
        }
        if let image = shows[indexPath.row].image.medium {
            cell.configure(withImageURL: image)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 210 * 0.5, height: 295 * 0.5)
    }
    
}

