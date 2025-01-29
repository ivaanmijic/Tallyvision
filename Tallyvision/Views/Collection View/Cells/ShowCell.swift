//
//  ShowCollectionViewCell.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 19. 11. 2024..
//

import UIKit

class ShowCell: UICollectionViewCell {
    
    static let identifier = "TV Show Cell"
    
    private(set) var imageURL: String? {
        didSet {
            setupImageView()
        }
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView.forAutoLayout()
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
        backgroundColor = .clear
        addSubview(imageView)
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        imageView.pin(to: self)
    }
    
    private func setupImageView() {
        imageView.configure(image: imageURL)
    }
    
    func configure(withImageURL imageURL: String?, alpha: CGFloat = 1) {
        self.imageURL = imageURL
        imageView.alpha = alpha
    }
    
}
