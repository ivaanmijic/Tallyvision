//
//  SeasonSelectionView.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 13. 1. 2025..
//

import UIKit

protocol SeasonSelectionViewDelegate: AnyObject {
    func selectSeason(withNumber number: Int64)
}

class SeasonSelectionView: UITableViewHeaderFooterView {
    // MARK: - Properties
    
    static let identifier = String(describing: SeasonSelectionView.self)
    
    weak var delegate: SeasonSelectionViewDelegate?
   
    var selectedSeason: Season? {
        didSet {
            createUIMenu()
            updateUI()
        }
    }

    var seasons: [Season] = []
//        didSet {
//            guard !seasons.isEmpty else { return }
//            selectedSeason = seasons[0]
//        }
//    }

    
    
    // MARK: - UI Components
    
    
    lazy var selectionButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.baseBackgroundColor = .secondaryAppColor
        configuration.baseForegroundColor = .textColor
        configuration.image = UIImage(systemName: "chevron.down")?
            .resizeTo(maxWidth: 18, maxHeight: 18)?
            .withTintColor(.textColor)
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 8
        configuration.cornerStyle = .medium
        
        let title = "Season 1"
        if let customFont = UIFont(name: "RedHatDisplay-Bold", size: 18) {
            var attributes = AttributedString(title)
            attributes.font = customFont
            configuration.attributedTitle = attributes
        }
        
        let button = UIButton(configuration: configuration, primaryAction: nil)
        button.layer.cornerRadius = 8
        button.backgroundColor = .secondaryAppColor
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var tvButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "television")!.withTintColor(.textColor.withAlphaComponent(0.5))
        button.setImage(image, for: .normal)
        return button.forAutoLayout()
    }()
    
    private lazy var episodesWatchedLabel = UILabel.appLabel(withText: "0", fontSize: 18, fontStyle: "bold").forAutoLayout()
    private lazy var slashLabel = UILabel.appLabel(withText: "/", fontSize: 18, fontStyle: "regular", alpha: 0.7).forAutoLayout()
    private lazy var totalEpisodesLabel = UILabel.appLabel(fontSize: 18, fontStyle: "bold").forAutoLayout()
    
    // MARK: - Initializers
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .appColor
        contentView.addSubview(selectionButton)
        contentView.addSubview(tvButton)
        
        contentView.addSubview(episodesWatchedLabel)
        contentView.addSubview(slashLabel)
        contentView.addSubview(totalEpisodesLabel)
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            selectionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            selectionButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            tvButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            tvButton.heightAnchor.constraint(equalToConstant: 30),
            tvButton.widthAnchor.constraint(equalToConstant: 30),
            tvButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            totalEpisodesLabel.trailingAnchor.constraint(equalTo: tvButton.leadingAnchor, constant: -16),
            totalEpisodesLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            slashLabel.trailingAnchor.constraint(equalTo: totalEpisodesLabel.leadingAnchor, constant: -4),
            slashLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            episodesWatchedLabel.trailingAnchor.constraint(equalTo: slashLabel.leadingAnchor, constant: -4),
            episodesWatchedLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),


        ])
    }
    
    // MARK: - Configuration
    func configure(seasons: [Season], selectedSeason: Season) {
        self.seasons = seasons
        self.selectedSeason = selectedSeason
    }
    
    
    // MARK: - Helpers
    
    private func createUIMenu() {
        
        let actions = seasons.map { season in
            UIAction(
                title: "Season \(season.number)",
                state: season.id == selectedSeason?.id ? .on : .off
            ) { [weak self] _ in
                guard let self = self else { return }
                self.selectedSeason = season
                self.createUIMenu()
                self.delegate?.selectSeason(withNumber: selectedSeason!.number)
            }
        }
        
        let menu = UIMenu(title: "Seasons", options: .displayInline, children: actions)
        
        selectionButton.menu = menu
        selectionButton.showsMenuAsPrimaryAction = true
    }
    
    private func updateUI() {
        guard let season = selectedSeason else { return }
        updateButtonTitle(selectionButton, withText: "Season \(season.number)")
        guard let episodeCount = season.episodeCount else {
            log.error("error")
            return
        }
        totalEpisodesLabel.text = "\(episodeCount)"
    }
    
    private func updateButtonTitle(_ button: UIButton, withText text: String) {
        guard var configuration = button.configuration else { return }
        
        if let font = UIFont(name: "RedHatDisplay-Bold", size: 18) {
            var attributtes = AttributedString(text)
            attributtes.font = font
            configuration.attributedTitle = attributtes
        }
        
        button.configuration = configuration
    }
    
}
