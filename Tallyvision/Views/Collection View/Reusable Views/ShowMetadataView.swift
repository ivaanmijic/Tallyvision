//
//  ShowMetadataView.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 17. 12. 2024..
//

import UIKit
import AlertKit



class ShowMetadataView: UICollectionReusableView {
    var show: Show?
    
    static let reuseIdentifier = "ShowMetadataView"
    
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .leading
        return stackView.forAutoLayout()
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 24
        stackView.alignment = .leading
        return stackView.forAutoLayout()
    }()
    
    private lazy var showTitle = ShowTitleView().forAutoLayout()
    
    private lazy var episodesButton: UIButton = {
        let button = UIButton(type: .custom)
        
        button.setTitle("Episodes  ", for: .normal)
        button.titleLabel?.font = UIFont(name: "RedHatDisplay-SemiBold", size: 18)
        button.setTitleColor(.textColor.withAlphaComponent(0.7), for: .normal)
        
        let iconImage = UIImage(systemName: "chevron.left")
        button.setImage(iconImage, for: .normal)
        button.tintColor = .textColor.withAlphaComponent(0.7)
        
        button.semanticContentAttribute = .forceRightToLeft
        
        button.backgroundColor = .clear
        
        return button.forAutoLayout()
    }()
    
    private lazy var introductionView = IntroductionView().forAutoLayout()
    
    private lazy var watchButton: AppButton = {
        let button = AppButton(color: .secondaryAppColor, image: UIImage(systemName: "play.tv.fill")!, frame: .zero)
        button.addTarget(self, action: #selector(openURL), for: .touchUpInside)
        return button.forAutoLayout()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.backgroundColor = .appColor
        self.layer.cornerRadius = 40
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.layer.masksToBounds = true
        
        addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 40),
            verticalStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            verticalStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
            verticalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
    }
    
    func configure(with show: Show?) {
        self.show = show
        
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if let rating = show?.rating {
            let ratingLabel = DecoratedLabel()
            ratingLabel.configure(icon: UIImage(systemName: "star.fill"), withColor: .systemYellow, text: "\(rating)")
            stackView.addArrangedSubview(ratingLabel)
        }
        
        if let premiereDate = show?.premiereDate {
            var yearsString = String(premiereDate.prefix(4))
            if let endDate = show?.endDate {
                let endYearString = String(endDate.prefix(4))
                yearsString = yearsString + " - " + endYearString
            }
            let dateLabel = DecoratedLabel()
            dateLabel.configure(icon: UIImage(systemName: "calendar"), withColor: .purple, text: yearsString)
            stackView.addArrangedSubview(dateLabel)
        }
        
        if let averageRuntime = show?.averageRuntime {
            let runtimeLabel = DecoratedLabel()
            runtimeLabel.configure(icon: UIImage(systemName: "clock.fill"), withColor: .gray, text: "\(averageRuntime) min")
            stackView.addArrangedSubview(runtimeLabel)
        }
        
        
        verticalStackView.addArrangedSubview(stackView)
        
        if let title = show?.title {
            showTitle.configure(title: title)
        }
        
        if let genres = show?.genres, genres.count != 0 {
            showTitle.configure(genres: genres)
        } else {
            showTitle.configure(genres: [show!.type])
        }
        
        verticalStackView.addArrangedSubview(showTitle)
        
        if let network = show?.network {
            log.debug(network.name)
            watchButton.configure(title: "Watch now on \(network.name)")
            verticalStackView.addArrangedSubview(watchButton)
            NSLayoutConstraint.activate([
                watchButton.widthAnchor.constraint(equalTo: verticalStackView.widthAnchor),
                watchButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        
        verticalStackView.addArrangedSubview(episodesButton)
        
        if let summary = show?.summary {
            introductionView.setText(summary)
            verticalStackView.addArrangedSubview(introductionView)
        }
        
        
    }
    
    // MARK: - Actions
    
    @objc private func openURL() {
        guard let urlString = show?.officialSite,
              let url = URL(string: urlString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:]) { succes in
                if succes {
                    log.info("URL successfully opened.")
                } else {
                    self.showAlert()
                }
            }
        } else {
            showAlert()
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
