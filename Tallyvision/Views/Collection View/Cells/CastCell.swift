//
//  CastCollectionViewCell.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 18. 12. 2024..
//

import UIKit

class CastCell: UICollectionViewCell {
   
    static let identifier = String(describing: CastCell.self)
    
    private var imageURL: String? {
        didSet {
            setupImageView()
        }
    }
   
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, nameLabel, characterLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.distribution = .fill
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
        label.numberOfLines = 2
        label.textAlignment = .center
        return label.forAutoLayout()
    }()
    
    lazy var characterLabel: UILabel = {
        let label = UILabel.appLabel(fontSize: 14, fontStyle: "Medium")
        label.numberOfLines = 2
        label.textAlignment = .center
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
        addSubview(stackView)
        activateConstraints()
    }
    
    
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func setupImageView() {
        imageView.configure(image: imageURL, placeholder: "actor")
    }
    
    func configure(name: String, characterName: String, imageURL: String?) {
        self.imageURL = imageURL
        self.nameLabel.text = name
        self.characterLabel.text = characterName
    }
    
}
