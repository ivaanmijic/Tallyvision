//
//  ShowCardView.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 12. 11. 2024..
//

import UIKit
import SDWebImage

class ShowCardView: UIView {
    
    lazy var poster: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
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
        addSubview(poster)
        activateConstraints()
    }
    
    private func activateConstraints() {
        poster.pin(to: self)
    }
    
    func configure(forShow show: Show) {
        guard let urlString = show.image.original, let imageURL = URL(string: urlString) else {
            log.error("ShowCardView: invalid url")
            return
        }
        poster.sd_setImage(with: imageURL)
    }
    
}

