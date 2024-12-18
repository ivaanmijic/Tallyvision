//
//  CastCollectionViewCell.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 18. 12. 2024..
//

import UIKit

class CastCollectionViewCell: UICollectionViewCell {
   
    static let identifier = String(describing: CastCollectionViewCell.self)
    
    private var imageURL: String? {
        didSet {
            setupImageView()
        }
    }
   
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, nameLabel, characterLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        return stackView.forAutoLayout()
    }()
  
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        return imageView.forAutoLayout()
    }()
    
        
    lazy var nameLabel: UILabel = {
        let label = UILabel.appLabel(fontSize: 14, fontStyle: "Bold")
        label.numberOfLines = 1
        return label.forAutoLayout()
    }()
    
    lazy var characterLabel: UILabel = {
        let label = UILabel.appLabel(fontSize: 14, fontStyle: "Medium")
        label.numberOfLines = 1
        return label.forAutoLayout()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .appBlue
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        addSubview(stackView)
        activateConstraints()
    }
    
    
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            imageView.widthAnchor.constraint(equalToConstant: 120),
            imageView.widthAnchor.constraint(equalToConstant: 160)
        ])
    }
    
    private func setupImageView() {
        if let imageURL = imageURL, let sd_imageURL = URL(string: imageURL) {
            imageView.sd_setImage(with: sd_imageURL)
        } else {
            imageView.image = UIImage(named: "placeholder")?.resizeTo(maxWidth: 120, maxHeight: 160)
        }
    }
    
    func configure(name: String, characterName: String, imageURL: String?) {
        self.imageURL = imageURL
        self.nameLabel.text = name
        self.characterLabel.text = characterName
    }
    
}
