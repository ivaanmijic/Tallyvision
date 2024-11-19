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
    private var initialCardCenter: CGPoint = .zero
    private var currentShowIndex = 0
    
    //MARK: - UIComponents
    
    lazy var titleLabel: UILabel = .screenTitle(withText: "HOME").forAutoLayout()
    lazy var recommendedShowsLabel: UILabel = .subTitle(withText: "Top shows this week").forAutoLayout()
    lazy var newEpisodesLabel: UILabel = .subTitle(withText: "New in subscriptions").forAutoLayout()
    lazy var recentShowsLabel: UILabel = .subTitle(withText: "Recent aired").forAutoLayout()
    lazy var upcomingShowsLabel: UILabel = .subTitle(withText: "Upcoming shows").forAutoLayout()
    
    lazy var tvShowCardView: TvShowCardView = {
        let view = TvShowCardView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        return view.forAutoLayout()
    }()
    
    lazy var dotsIndicator = DotsIndicatorView().forAutoLayout()
    lazy var blurredBackground = BlurredImageView().forAutoLayout()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        view.addSubview(recommendedShowsLabel)
        view.addSubview(tvShowCardView)
        view.addSubview(dotsIndicator)
        view.insertSubview(blurredBackground, belowSubview: recommendedShowsLabel)
    }
    
    private func configureDotsIndicator() {
        dotsIndicator.configureDots(count: 5)
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
    }
    
   
    // MARK: - Pan Gesture Setup
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            recommendedShowsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            recommendedShowsLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            recommendedShowsLabel.heightAnchor.constraint(equalToConstant: 30),
            
            tvShowCardView.topAnchor.constraint(equalTo: recommendedShowsLabel.bottomAnchor, constant: 16),
            tvShowCardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tvShowCardView.widthAnchor.constraint(equalToConstant: 272 * 1.1),
            tvShowCardView.heightAnchor.constraint(equalToConstant: 400 * 1.1),
            
            blurredBackground.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            blurredBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -60),
            blurredBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 60),
            blurredBackground.heightAnchor.constraint(equalToConstant: (view.frame.width + 120) * 1000 / 680),
            
            dotsIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dotsIndicator.topAnchor.constraint(equalTo: tvShowCardView.bottomAnchor, constant: 10),
            dotsIndicator.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
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
        case .changed:
            updateCardPositionWithTranslation(translation)
        case .ended:
            handlePanGestureEnd(translation: translation, velocity: velocity)
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
        let swipeThreshold: CGFloat = 100
        let velocityThreshold: CGFloat = 500
        
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
            tvShowCards?.goToNextShow()
        }
    }
    
    private func updateCardPosition(reset: Bool = false) {
        UIView.animate(withDuration: 0.3) {
            if reset == true {
                self.tvShowCardView.center = self.initialCardCenter
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
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    private func fetchShows() async {
        do {
            let shows = try await TVMazeClient.shared.fetchShows()
            let dropedShows = Array(shows.dropFirst(shows.count - 5))
            log.info(dropedShows.count)
            tvShowCards = ShowCards(shows: dropedShows)
            
        } catch {
            log.error("Error fetching shows\n\(error)")
        }
    }
    
}

