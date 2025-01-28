//
//  EpisodesTableViewCell.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 11. 1. 2025..
//

import UIKit

protocol EpisodeTableViewCellDelegate: AnyObject {
    func episodeSeenStatusChanged(for episode: Episode)
}

class EpisodeTableViewCell: UITableViewCell {
    // MARK: - Properties
   
    static let identifier = String(describing: EpisodeTableViewCell.self)
    weak var delegate: EpisodeTableViewCellDelegate?
   
    private var episode: Episode? {
        didSet {
            updateUI()
        }
    }
    
    private var isEpisodeWatched: Bool? {
        didSet {
            setTvButtonAppearance(isEpisodeWatched: isEpisodeWatched ?? false)
        }
    }
    
    // MARK: - UIComponents
    
    lazy var tvIcon = UIImage(named: "television")!
    
    lazy var poster: UIImageView = {
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
        button.addTarget(self, action: #selector(toggleEpisodeSeenStatus), for: .touchUpInside)
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
    
    // MARK: - Intializers
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .appColor
       
        stackView.addArrangedSubview(orderLabel)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(premiereLabel)
        
        contentView.addSubview(poster)
        contentView.addSubview(stackView)
        contentView.addSubview(tvButton)
    }
    
    private func activateConstraints() {
        let imageWidth = AppConstants.screenWidth / 3
        
        NSLayoutConstraint.activate([
            poster.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            poster.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            poster.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            poster.widthAnchor.constraint(equalToConstant: imageWidth),
            poster.heightAnchor.constraint(equalTo: poster.widthAnchor, multiplier: AppConstants.episodeImageRation),
           
            tvButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            tvButton.heightAnchor.constraint(equalToConstant: 30),
            tvButton.widthAnchor.constraint(equalToConstant: 30),
            tvButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: poster.trailingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: tvButton.leadingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: poster.centerYAnchor)
        ])
    }
   
    // MARK: - Configuration
    func configure(episode: Episode, status: Bool) {
        self.episode = episode
        self.isEpisodeWatched = status
    }
    
    private func updateUI() {
        guard let episode = self.episode else { return }
        poster.configure(image: episode.image?.medium, placeholder: "show")
        setTvButtonAppearance(isEpisodeWatched: episode.hasBeenSeen)
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

    @objc private func toggleEpisodeSeenStatus() {
        guard let episode = episode else { return }
        delegate?.episodeSeenStatusChanged(for: episode)
        setTvButtonAppearance(isEpisodeWatched: !episode.hasBeenSeen)
    }
    
    // MARK: - Helpers
    
    private func setTvButtonAppearance(isEpisodeWatched: Bool) {
        let color: UIColor = isEpisodeWatched == true ? .baseYellow : .textColor.withAlphaComponent(0.5)
        tvButton.setImage(tvIcon.withTintColor(color), for: .normal)
    }
    
}
