//
//  GenreCell.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 17. 12. 2024..
//

import UIKit

class GenreCell: UICollectionViewCell {
    static let identifier = "genre cell"
    
    lazy var genreLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = UIFont(name: "RedHatDisplay-Bold", size: 16)
        label.backgroundColor = .appBlue
        label.textColor = .textColor
        label.textAlignment = .center
        label.layer.cornerRadius = 18
        label.clipsToBounds = true
        return label.forAutoLayout()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        contentView.addSubview(genreLabel)
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            genreLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            genreLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            genreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            genreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func configure(with genre: String) {
        genreLabel.text = genre
    }
}
