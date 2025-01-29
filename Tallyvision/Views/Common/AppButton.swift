//
//  AppButton.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 8. 1. 2025..
//

import UIKit

class AppButton: UIButton {
    
    var color: UIColor
    var image: UIImage
    
    lazy var label = UILabel.appLabel(fontSize: 18, fontStyle: "Regular").forAutoLayout()
    
    lazy var buttonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .textColor
        return imageView.forAutoLayout()
    }()
    
    init(color: UIColor, image: UIImage, frame: CGRect) {
        self.color = color
        self.image = image
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        layer.cornerRadius = 10
        backgroundColor = color
        layer.masksToBounds = true
        buttonImageView.image = image
        addSubviews()
        activateConstraints()
    }
    
    private func addSubviews() {
        addSubview(buttonImageView)
        addSubview(label)
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            buttonImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            buttonImageView.heightAnchor.constraint(equalToConstant: 20),
            buttonImageView.widthAnchor.constraint(equalToConstant: 20),
            buttonImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7)
        ])
    }
    
    
    func configure(title: String) {
        label.text = title
    }
    
    func updateButtonAppearance(isListed: Bool) {
        if isListed {
            self.backgroundColor = .appGreen
            self.buttonImageView.image = UIImage(named: "check_circle")!.withTintColor(.white)
            self.label.text = "Listed"
            self.label.textColor = .white
        } else {
            self.backgroundColor = .baseYellow
            self.label.textColor = .black
            self.buttonImageView.image = UIImage(named: "bookmark")!.withTintColor(.black)
            self.label.text = "Add to Watchlist"
        }
    }
}
