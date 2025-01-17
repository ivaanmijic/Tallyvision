//
//  EpisodesTableViewCell.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 11. 1. 2025..
//

import UIKit

class EpisodesTableViewCell: UITableViewCell {
    // MARK: - Properties
    
    static let identifier = String(describing: EpisodesTableViewCell.self)
    
    private var episode: Episode? {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - UIComponents
    
    private lazy var orderLabel: UILabel = {
        let label = UILabel.appLabel(fontSize: 38, fontStyle: "bold")
        label.textColor = .secondaryAppColor
        label.textAlignment = .center
        return label.forAutoLayout()
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel.appLabel(fontSize: 18, fontStyle: "bold")
        label.numberOfLines = 1
        return label.forAutoLayout()
    }()
    
    private lazy var premiereLabel: UILabel = {
        let label = UILabel.appLabel(fontSize: 16, fontStyle: "regular", alpha: 0.7)
        label.numberOfLines = 1
        return label.forAutoLayout()
    }()
    
    private lazy var tvButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "television")!.withTintColor(.secondaryAppColor)
        button.setImage(image, for: .normal)
        return button.forAutoLayout()
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
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
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(premiereLabel)
        
        contentView.addSubview(orderLabel)
        contentView.addSubview(stackView)
        contentView.addSubview(tvButton)
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            orderLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            orderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            orderLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            orderLabel.widthAnchor.constraint(equalToConstant: 75),
           
            tvButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            tvButton.heightAnchor.constraint(equalToConstant: 30),
            tvButton.widthAnchor.constraint(equalToConstant: 30),
            tvButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: orderLabel.trailingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: tvButton.leadingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: orderLabel.centerYAnchor)
        ])
    }
   
    // MARK: - Configuration
    func configure(episode: Episode) {
        self.episode = episode
    }
    
    private func updateUI() {
        guard let episode = self.episode else { return }
        orderLabel.text = "\(episode.number ?? 0)"
        titleLabel.text = episode.title
        premiereLabel.text = episode.airdate?.formattedDate()
    }
    
}
