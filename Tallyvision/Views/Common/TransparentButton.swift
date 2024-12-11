//
//  BackButton.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 3. 12. 2024..
//

import UIKit

class TransparentButton: UIButton {
   
    lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = self.layer.cornerRadius
        blurView.frame = self.bounds
        blurView.clipsToBounds = true
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isUserInteractionEnabled = false
        return blurView.forAutoLayout()
    }()
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        layer.cornerRadius = 20
        clipsToBounds = true
        tintColor = .white
        insertSubview(blurEffectView, belowSubview: self.imageView!)
    }

}
