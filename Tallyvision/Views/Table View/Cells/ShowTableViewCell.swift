//
//  ShowTableViewCell.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 7. 1. 2025..
//

import UIKit

class ShowTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: ShowTableViewCell.self)
    
    private var show: Show? {
        didSet {
            updateUI()
        }
    }
    
    private lazy var cellView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = .secondaryAppColor
        return view.forAutoLayout()
    }()
   
    private lazy var poster: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView.forAutoLayout()
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.appLabel( fontSize: 20, fontStyle: "SemiBold").forAutoLayout()
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label.forAutoLayout()
    }()

    private lazy var firstSubtitleLabel: UILabel = {
        let label = UILabel.appLabel( fontSize: 16, fontStyle: "Regular", alpha: 0.7).forAutoLayout()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label.forAutoLayout()
    }()

    private lazy var secondSubtitleLabel: UILabel = {
        let label = UILabel.appLabel( fontSize: 16, fontStyle: "Regular", alpha: 0.5).forAutoLayout()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label.forAutoLayout()
    }()
    
    private lazy var ratingLabel = DecoratedLabel().forAutoLayout()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(cellView)
        cellView.addSubview(poster)
        cellView.addSubview(titleLabel)
        cellView.addSubview(firstSubtitleLabel)
        cellView.addSubview(secondSubtitleLabel)
        cellView.addSubview(ratingLabel)
    }
    
    private func activateConstraints() {
        let imageWidth = AppConstants.screenWidth / 6
        let imageHeight = imageWidth * AppConstants.posterImageRatio
        let cellHeight = imageHeight + 20
        
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
                cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
                cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                cellView.heightAnchor.constraint(equalToConstant: cellHeight),

                ratingLabel.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 25),
                ratingLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -10),

                poster.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 10),
                poster.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 10),
                poster.widthAnchor.constraint(equalToConstant: imageWidth),
                poster.heightAnchor.constraint(equalToConstant: imageHeight),

                titleLabel.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 10),
                titleLabel.leadingAnchor.constraint(equalTo: poster.trailingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: ratingLabel.leadingAnchor, constant: -10),

                firstSubtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
                firstSubtitleLabel.leadingAnchor.constraint(equalTo: poster.trailingAnchor, constant: 16),
                firstSubtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: cellView.trailingAnchor, constant: -10),

                secondSubtitleLabel.topAnchor.constraint(equalTo: firstSubtitleLabel.bottomAnchor, constant: 5),
                secondSubtitleLabel.leadingAnchor.constraint(equalTo: poster.trailingAnchor, constant: 16),
                secondSubtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: cellView.trailingAnchor, constant: -10),
                secondSubtitleLabel.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - UI Update
    private func updateUI() {
        guard let show = show else { return }
        
        poster.configure(image: show.image?.medium, placeholder: "placeholder")
        titleLabel.text = show.title
        
        if let premiereDate = show.premiereDate {
            let premierYear = premiereDate.prefix(4)
            let endYear = show.endDate?.prefix(4) ?? "Present"
            firstSubtitleLabel.text = "\(premierYear) - \(endYear)"
        }
        
        let genres = show.genres.joined(separator: ", ")
        let secondSubtitle = genres.count != 0 ? "\(genres)" : "\(show.type)"
        secondSubtitleLabel.text = secondSubtitle
        
        if let rating = show.rating {
            ratingLabel.configure(icon: UIImage(systemName: "star.fill"), withColor: .baseYellow, text: String("\(rating)"))
        }
    }
    
    func configure(withShow show: Show) {
        self.show = show
    }
    
}
