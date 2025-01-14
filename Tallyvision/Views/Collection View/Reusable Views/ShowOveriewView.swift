//
//  ShowMetadataView.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 17. 12. 2024..
//

import UIKit
import AlertKit

protocol ShowOveriewDelegate: AnyObject {
    func presentEpisodes()
}

class ShowOveriewView: UICollectionReusableView {
    // MARK: - Properties
    
    weak var delegate: ShowOveriewDelegate?
    
    var show: Show?
    var seasons: [Season]?
    static let reuseIdentifier = "ShowMetadataView"
    
    // MARK: - UI Components
    
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .leading
        return stackView.forAutoLayout()
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 24
        stackView.alignment = .leading
        return stackView.forAutoLayout()
    }()
    
    private lazy var showTitleView = ShowTitleView().forAutoLayout()
    
    private lazy var storylineView = StorylineView().forAutoLayout()
    
    private lazy var watchButton: AppButton = {
        let button = AppButton(
            color: .secondaryAppColor,
            image: UIImage(systemName: "play.tv.fill")!,
            frame: .zero
        )
        button.addTarget(self, action: #selector(openURL), for: .touchUpInside)
        return button.forAutoLayout()
    }()
    
    lazy var episodesContainerView = UIView().forAutoLayout()
    
    lazy var episodesLabel: UILabel = {
        let label = UILabel().forAutoLayout()
        label.numberOfLines = 1
        label.textAlignment = .left
        return label.forAutoLayout()
    }()
    
    lazy var episodesButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont(name: "RedHatDisplay-SemiBold", size: 18)
        button.setTitleColor(.baseYellow, for: .normal)
        button.setTitle("See All", for: .normal)
        button.addTarget(self, action: #selector(presentEpisodes), for: .touchUpInside)
        return button.forAutoLayout()
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup Methods
    
    private func setupView() {
        self.backgroundColor = .appColor
        self.layer.cornerRadius = 40
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.layer.masksToBounds = true
        
        addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 30),
            verticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            verticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            verticalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(withShow show: Show?, seasons: [Season]?) {
        self.show = show
        self.seasons = seasons
        resetStackViews()
        
        configureMetadata()
        configureTitleView()
        configureWatchButton()
        configureEpisodesView()
        configureStorylineView()
    }
    
    private func resetStackViews() {
        horizontalStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        verticalStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    private func configureMetadata() {
        if let rating = show?.rating {
            horizontalStackView.addArrangedSubview(createDecoratedLabel(icon: "star.fill", color: .systemYellow, text: "\(rating)"))
        }
        
        if let premiereDate = show?.premiereDate {
            var dateText = String(premiereDate.prefix(4))
            if let endDate = show?.endDate {
                dateText += " - " + String(endDate.prefix(4))
            }
            horizontalStackView.addArrangedSubview(createDecoratedLabel(icon: "calendar", color: .purple, text: dateText))
        }
        
        if let runtime = show?.averageRuntime {
            let hours = runtime / 60
            let minutes = runtime % 60
            let formattedRuntime: String
            
            if hours > 0 {
                formattedRuntime = minutes > 0 ? "\(hours) h \(minutes) min" : "\(hours) h"
            } else {
                formattedRuntime = minutes > 0 ? "\(minutes) min" : "0 min"
            }
            
            horizontalStackView.addArrangedSubview(createDecoratedLabel(icon: "clock.fill", color: .gray, text: formattedRuntime))
        }
        
        verticalStackView.addArrangedSubview(horizontalStackView)
    }
    
    private func configureTitleView() {
        if let title = show?.title {
            showTitleView.configure(title: title)
        }
        
        var string = [String]()
        if let show = show {
            if show.genres.isEmpty { string = [show.type] }
            else { string = show.genres }
        }
        showTitleView.configure(genres: string)
        
        verticalStackView.addArrangedSubview(showTitleView)
    }
    
    private func configureWatchButton() {
        guard let network = show?.network else { return }
        
        watchButton.configure(title: "Watch now on \(network.name)")
        verticalStackView.addArrangedSubview(watchButton)
        
        NSLayoutConstraint.activate([
            watchButton.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor),
            watchButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureEpisodesView() {
        guard let seasons = seasons else { return }
        
        let episodesCount = calculateEpisodesCount(from: seasons)
        let showIsShowing = episodesCount > 0
        let detailText = showIsShowing ? "\(episodesCount)" : "Not Available"
        
        configureEpisodesLabel(with: detailText)
        configureEpisodesButton(isEnabled: showIsShowing)
        setupEpisodesContainerView()
    }
    
    private func configureStorylineView() {
        guard let summary = show?.summary else { return }
        storylineView.setText(summary)
        verticalStackView.addArrangedSubview(storylineView)
    }
    
    private func createDecoratedLabel(icon: String, color: UIColor, text: String) -> DecoratedLabel {
        let label = DecoratedLabel()
        label.configure(icon: UIImage(systemName: icon), withColor: color, text: text)
        return label
    }
    
    private func calculateEpisodesCount(from seasons: [Season]) -> Int64 {
        return seasons.compactMap { $0.episodeCount }.reduce(0, +)
    }
    
    private func configureEpisodesLabel(with detailText: String) {
        episodesLabel.attributedText = createAttributtedEpisodesText(detail: detailText)
    }
    
    private func configureEpisodesButton(isEnabled: Bool) {
        episodesButton.isEnabled = isEnabled
        episodesButton.isHidden = !isEnabled
    }
    
    private func setupEpisodesContainerView() {
        [episodesLabel, episodesButton].forEach { episodesContainerView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            episodesLabel.topAnchor.constraint(equalTo: episodesContainerView.topAnchor),
            episodesLabel.bottomAnchor.constraint(equalTo: episodesContainerView.bottomAnchor),
            episodesLabel.leadingAnchor.constraint(equalTo: episodesContainerView.leadingAnchor),
            episodesLabel.trailingAnchor.constraint(lessThanOrEqualTo: episodesButton.leadingAnchor, constant: -8),
            
            episodesButton.topAnchor.constraint(equalTo: episodesContainerView.topAnchor),
            episodesButton.bottomAnchor.constraint(equalTo: episodesContainerView.bottomAnchor),
            episodesButton.trailingAnchor.constraint(equalTo: episodesContainerView.trailingAnchor)
        ])
        
        verticalStackView.addArrangedSubview(episodesContainerView)
        episodesContainerView.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor).isActive = true
    }
    
    private func createAttributtedEpisodesText(detail: String) -> NSAttributedString {
        let attributtedText = NSMutableAttributedString(
            string: "Episodes: ",
            attributes: [
                .font: UIFont(name: "RedHatDisplay-Bold", size: 18)!,
                .foregroundColor: UIColor.textColor
            ]
        )
        
        let detailAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "RedHatDisplay-Regular", size: 18)!,
            .foregroundColor: UIColor.textColor.withAlphaComponent(0.7)
        ]
        attributtedText.append(NSAttributedString(string: detail, attributes: detailAttributes))
        
        return attributtedText
    }
    
    // MARK: - Actions
    
    @objc private func presentEpisodes() {
        delegate?.presentEpisodes()
    }
    
    @objc private func openURL() {
        guard let urlString = show?.officialSite,
              let url = URL(string: urlString) else {
            return showAlert()
        }
        
        UIApplication.shared.open(url, options: [:]) { succes in
            if succes {
                log.info("URL successfully opened.")
            } else {
                self.showAlert()
            }
        }
    }
    
    private func showAlert() {
        let message = "Failed to open URL."
        log.error(message)
        AlertKitAPI.present(
            title: message,
            icon: .error,
            style: .iOS17AppleMusic
        )
    }
}
