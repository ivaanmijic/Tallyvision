//
//  BlurredImageView.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 13. 11. 2024..
//

import UIKit

class BlurredImageView: UIImageView {

    private let gradientLayer = CAGradientLayer()
    private let blurEffectView = UIVisualEffectView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBlur()
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBlur()
        setupGradient()
    }
   
    override init(image: UIImage?) {
        super.init(image: image)
        setupBlur()
        setupGradient()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    private func setupBlur() {
        let blurEffect = UIBlurEffect(style: .prominent)
        blurEffectView.effect = blurEffect
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurEffectView)
    }
    
    private func setupGradient() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.systemBackground.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.locations = [0.0, 1.0]
        blurEffectView.contentView.layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurEffectView.frame = bounds
        gradientLayer.frame = bounds
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if var colors = gradientLayer.colors as? [CGColor] {
            colors[1] = UIColor.systemBackground.cgColor
            gradientLayer.colors = colors
        }
    }
    
    func configure(forShow show: Show) {
        guard let urlString = show.image.original, let imageURL = URL(string: urlString) else {
            log.error("ShowCardView: invalid url")
            return
        }
        self.sd_setImage(with: imageURL)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
