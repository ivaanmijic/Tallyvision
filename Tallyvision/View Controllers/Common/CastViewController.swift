//
//  CastDetailsViewController.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 18. 12. 2024..
//

import UIKit
import Vision

protocol CastViewControllerDelegate: AnyObject {
    func pushShowViewController(for show: Show)
}

class CastViewController: UIViewController {
    
    weak var delegate: CastViewControllerDelegate?
    
    var actor: Person
    var shows = [Show]()
    
    var castService: CastService!
    
    // MARK: UI Components
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView.forAutoLayout()
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel.appLabel(fontSize: 24, fontStyle: "bold")
        label.textAlignment = .left
        label.numberOfLines = 0
        return label.forAutoLayout()
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.distribution = .fillProportionally
        return stackView.forAutoLayout()
    }()
    
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
       
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ShowCell.self, forCellWithReuseIdentifier: ShowCell.identifier)
        collectionView.register(
            SectionTitleReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionTitleReusableView.identifier
        )
        
        return collectionView.forAutoLayout()
    }()
    
    // MARK: - Intializers
    
    init(actor: Person) {
        self.actor = actor
        super.init(nibName: nil, bundle: nil)
        self.castService = CastService(httpClinet: TVMazeClient())
        updateUI()
        log.info("Cast Details View Contrller has been loaded for: \(actor.id)")
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    private func setupUI() {
        view.backgroundColor = .secondaryAppColor
        addSubviews()
        configureCollectionView()
        configureCompositionalLayout()
        activateConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(profileImageView)
        view.addSubview(contentStackView)
        view.addSubview(collectionView)
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .secondaryAppColor
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func configureCompositionalLayout() {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            return AppLayouts.shared.posterSection()
        }
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    
    private func activateConstraints() {
        let imageWidth = AppConstants.screenWidth * 0.3
        let imageHeight = imageWidth * AppConstants.posterImageRatio
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            profileImageView.widthAnchor.constraint(equalToConstant: imageWidth),
            profileImageView.heightAnchor.constraint(equalToConstant: imageHeight),
            
            contentStackView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            
            collectionView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    // MARK: UI Update
    
    private func updateUI() {
        updateImage()
        updateLabels()
        
        Task {
            await updateShows()
            collectionView.reloadData()
        }
        
    }
    
    private func updateImage() {
        let image = actor.image?.original
        profileImageView.configure(image: image, placeholder: "placeholder")
    }
    
    private func updateLabels() {
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        nameLabel.text = actor.name
        contentStackView.addArrangedSubview(nameLabel)
        
        if let gender = actor.gender {
            contentStackView.addArrangedSubview(createKeyValueLabel(key: "Gender", value: gender))
        }
        
        if let birthday = actor.birthday {
            contentStackView.addArrangedSubview(createKeyValueLabel(key: "Born: ", value: formattedDate(birthday)))
        }
        
        if let deathday = actor.deathday {
            contentStackView.addArrangedSubview(createKeyValueLabel(key: "Death", value: formattedDate(deathday)))
        }
        
        if let country = actor.country {
            contentStackView.addArrangedSubview(createKeyValueLabel(key: "Nationality: ", value: country.name))
        }
    }
    
    private func updateShows() async {
        do {
            shows = try await castService.getCastCredit(personId: actor.id)
        } catch {
            log.error("CastDetailsVC: updateShows()")
        }
    }
    
    // MARK: - Helper methods
    
    private func createKeyValueLabel(key: String, value: String) -> UIView {
        let container = UIView()
        
        let keyLabel = createLabel(text: key, fontSize: 16, fontStyle: "bold", textColor: .textColor)
        let valueLabel = createLabel(text: value, fontSize: 16, fontStyle: "regular", textColor: .textColor.withAlphaComponent(0.7))
        
        [keyLabel, valueLabel].forEach {
            container.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            keyLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            keyLabel.topAnchor.constraint(equalTo: container.topAnchor),
            keyLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            
            valueLabel.leadingAnchor.constraint(equalTo: keyLabel.trailingAnchor, constant: 4),
            valueLabel.topAnchor.constraint(equalTo: container.topAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor)
        ])
        
        return container.forAutoLayout()
    }
    
    private func createLabel(text: String, fontSize: CGFloat, fontStyle: String, textColor: UIColor) -> UILabel {
        let label = UILabel.appLabel(fontSize: fontSize, fontStyle: fontStyle)
        label.text = text
        label.textColor = textColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func formattedDate(_ date: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let parsedDate = formatter.date(from: date) {
            formatter.dateStyle = .medium
            return formatter.string(from: parsedDate)
        }
        return date
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension CastViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShowCell.identifier, for: indexPath)
                as? ShowCell else {
            return UICollectionViewCell()
        }
        
        if let image = shows[indexPath.row].image,
           let imageURL = image.medium {
            cell.configure(withImageURL: imageURL)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader,
           let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SectionTitleReusableView.identifier,
            for: indexPath
           ) as? SectionTitleReusableView {
            header.configure(title: "Known for:")
            return header
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.pushShowViewController(for: self.shows[indexPath.row])
        }
    }
    
}

extension CastViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0
    }
    
}
