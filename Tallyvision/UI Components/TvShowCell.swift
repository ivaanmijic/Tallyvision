//
//  ShowCollectionViewCell.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 19. 11. 2024..
//

import UIKit

class TvShowCell: UICollectionViewCell {
    
    static let identifier = "TV Show Cell"
    
    private(set) var imageURL: String? {
        didSet {
            setupImageView()
        }
    }
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 20
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
        imageView.pin(to: self)
        self.layer.cornerRadius = 20
    }
    
    private func setupImageView() {
        guard let imageURL = imageURL, let sd_imageURL = URL(string: imageURL) else { return }
        imageView.sd_setImage(with: sd_imageURL)
    }
    
    func configure(withImageURL imageURL: String) {
        self.imageURL = imageURL
    }

    
}
