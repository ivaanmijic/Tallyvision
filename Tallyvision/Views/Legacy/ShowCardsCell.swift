//
//  ShowCardReusableView.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 26. 11. 2024..
//

import UIKit

class ShowCardsCell: UICollectionViewCell {
    
    // MARK: Properties
    static let identifier = "ShowCardReusableView"
    
    private var initialCardCenter: CGPoint = .zero
    private var currentShowIndex = 0
//    var showCards: ShowCards?
    
    // MARK: UI Component
    
    lazy var showCardView: ShowCardView = {
        let view = ShowCardView()
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        return view.forAutoLayout()
    }()
    
    lazy var dotsIndicator = DotsIndicatorView().forAutoLayout()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubviews()
        setupConstraints()
        setupPanGesture()
    }
    
    private func addSubviews() {

        addSubview(showCardView)
        addSubview(dotsIndicator)
    }
    
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            showCardView.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            showCardView.centerXAnchor.constraint(equalTo: centerXAnchor),
            showCardView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            showCardView.heightAnchor.constraint(equalToConstant: 400 * 1.2),
            
            dotsIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            dotsIndicator.topAnchor.constraint(equalTo: showCardView.bottomAnchor, constant: 10),
            dotsIndicator.heightAnchor.constraint(equalToConstant: 40),
            
        ])
    }
    
    func configure(withShows shows: [Show]) {
//        showCards = ShowCards(shows: shows)
        configureDotsIndicator(count: shows.count)
    }
    
    func configureDotsIndicator(count: Int) {
        dotsIndicator.configureDots(count: count)
    }
    // MARK: - Pan Gesture Setup
   
    
    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.delegate = self
        showCardView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)
       
        let isVerticalPanGesture = abs(translation.x) < abs(translation.y)
        if isVerticalPanGesture {
            gesture.setTranslation(.zero, in: self)
        }
        
        else {
            switch gesture.state {
            case .began:
                initialCardCenter = showCardView.center
            case .changed:
                updateCardPositionWithTranslation(translation)
            case .ended:
                handlePanGestureEnd(translation: translation, velocity: velocity)
            default:
                break
            }
        }
    }
   
    
    private func updateCardPositionWithTranslation(_ translation: CGPoint) {
        showCardView.center = CGPoint(x: initialCardCenter.x + translation.x, y: initialCardCenter.y)
        let rotationAngle = translation.x / 2000
        showCardView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        
        let scale = 1 - min(abs(translation.x) / 300, 0.2)
        showCardView.transform = showCardView.transform.scaledBy(x: scale, y: scale)
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
        let offScreenX = direction * frame.width * 1.5
        UIView.animate(withDuration: 0.3, animations: {
            self.showCardView.center = CGPoint(x: self.showCardView.center.x + offScreenX, y: self.showCardView.center.y)
            self.showCardView.alpha = 0
        }) { [weak self] _ in
            self?.updateShowIndex(forDirection: direction)
            self?.updateRecommendedShow()
            self?.updateCardPosition()
        }
    }
    
    private func updateShowIndex(forDirection direction: CGFloat) {
        if direction > 0 {
            currentShowIndex -= 1
//            showCards?.goToNextShow()
        } else {
            currentShowIndex += 1
//            showCards?.goToPrevShow()
        }
    }
    
    private func updateCardPosition(reset: Bool = false) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            if reset == true {
                resetCardPosition()
            }
            self.showCardView.alpha = 1
            self.showCardView.transform = CGAffineTransform.identity
        }
    }

    
    private func updateRecommendedShow() {
//        guard let currentShow = showCards?.currentShow() else { return }
//        showCardView.configure(forShow: currentShow)
        dotsIndicator.highlightDot(atIndex: currentShowIndex)
        resetCardPosition()
    }
    
    private func resetCardPosition() {
        showCardView.center = initialCardCenter
    }
}

// MARK: - UIGesureRecognizerDelegate

extension ShowCardsCell: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGesture.translation(in: self)
            let isVerticalSwipe = abs(translation.y) > abs(translation.x)
            if isVerticalSwipe { return true }
        }
        return false
        
    }
}
