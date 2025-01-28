//
//  EpisodeCollectionViewCell.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 27. 1. 2025..
//

import UIKit

protocol EpisodeCollectionViewCellDelegate: AnyObject {
    func checkButtonClicked(for episode: Episode)
}

class EpisodeCollectionViewCell: UICollectionViewCell {
    // MARK: - Properites
    weak var delegate: EpisodeCollectionViewCellDelegate?
    
    static let identifier = String(describing: EpisodeCollectionViewCell.self)
    
    private var episode: Episode? {
        didSet {
            updateUI()
        }
    }
    
    private lazy var cellView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryAppColor
        return view.forAutoLayout()
    }()
    
    private lazy var poster: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView.forAutoLayout()
    }()
    
    private lazy var orderLabel: UILabel = {
        let label = UILabel.appLabel(fontSize: 18, fontStyle: "Bold")
        label.textAlignment = .center
        return label.forAutoLayout()
    }()
    
    private lazy var showTitleLabel: UILabel = {
        let label = UILabel.appLabel(fontSize: 16, fontStyle: "Bold", alpha: 0.8)
        label.numberOfLines = 1
        return label.forAutoLayout()
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.appLabel(fontSize: 14, fontStyle: "Bold", alpha: 0.7)
        label.numberOfLines = 2
        return label.forAutoLayout()
    }()
    
    private lazy var premiereLabel: UILabel = {
        let label = UILabel.appLabel(fontSize: 14, fontStyle: "Regular", alpha: 0.7)
        label.numberOfLines = 1
        return label.forAutoLayout()
    }()
    
    private lazy var tvButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "television")!.withTintColor(.textColor.withAlphaComponent(0.5))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(checkButtonClicked), for: .touchUpInside)
        return button.forAutoLayout()
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        return stackView.forAutoLayout()
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        contentView.addSubview(cellView)
        
        stackView.addArrangedSubview(orderLabel)
        stackView.addArrangedSubview(showTitleLabel)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(premiereLabel)
        
        cellView.addSubview(poster)
        cellView.addSubview(stackView)
        cellView.addSubview(tvButton)
    }
    
    private func activateConstraints() {
        let imageWidth = AppConstants.screenWidth / 3
       
        cellView.pin(to: contentView)
        NSLayoutConstraint.activate([
            poster.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 0),
            poster.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 0),
            poster.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: 0),
            poster.widthAnchor.constraint(equalToConstant: imageWidth),
            poster.heightAnchor.constraint(equalTo: poster.widthAnchor, multiplier: AppConstants.episodeImageRation),
            
            tvButton.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -24),
            tvButton.heightAnchor.constraint(equalToConstant: 30),
            tvButton.widthAnchor.constraint(equalToConstant: 30),
            tvButton.centerYAnchor.constraint(equalTo: cellView.centerYAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: poster.trailingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: tvButton.leadingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: poster.centerYAnchor)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(episode: Episode, showTitle: String, buttonDisabled: Bool = false) {
        self.episode = episode
        self.showTitleLabel.text = showTitle
        tvButton.isHidden = buttonDisabled
    }
    
    private func updateUI() {
        guard let episode = self.episode else { return }
        poster.configure(image: episode.image?.medium, placeholder: "show")
        configureOrderLabel()
        titleLabel.text = episode.title
        premiereLabel.text = episode.airdate?.formattedDate()
    }
    
    private func configureOrderLabel() {
        if let number = episode?.number,
           let seasonNumber = episode?.season {
            let formattedSeason = String(format: "S%02d", seasonNumber)
            let formattedEpisode = String(format: "E%02d", number)
            orderLabel.text = "\(formattedSeason) \(formattedEpisode)"
        } else {
            orderLabel.text = "Special"
        }
    }
    
    // MARK: - Actions
    
    @objc private func checkButtonClicked() {
        guard let episode = episode else { return }
        delegate?.checkButtonClicked(for: episode)
    }
    
}
