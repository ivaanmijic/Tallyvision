//
//  CastDetailsViewController.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 18. 12. 2024..
//

import UIKit

class CastDetailsViewController: UIViewController {
    
    var actor: Person
    var shows = [Show]()
    
    var castService: CastService!
    
    // MARK: UI Components
    
    private lazy var backButton: TransparentButton = {
        let button = TransparentButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveButton: TransparentButton = {
        let button = TransparentButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
//        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return button
    }()
    
    private lazy var blurredImage = BlurredImageView().forAutoLayout()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .appColor
        view.layer.cornerRadius = 40
        view.layer.masksToBounds = true
        return view.forAutoLayout()
    }()
    
    private lazy var actorImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        return imageView.forAutoLayout()
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel.appLabel(fontSize: 32, fontStyle: "bold")
        label.textAlignment = .center
        return label.forAutoLayout()
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
        
        return stackView.forAutoLayout()
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        
        collectionView.register(ShowCell.self, forCellWithReuseIdentifier: ShowCell.identifier)
        collectionView.register(
            SectionTitleReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionTitleReusableView.identifier
        )
        
        return collectionView.forAutoLayout()
    }()
    
    // MARK: - Constructors
    
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
        setupNavigationBar()
        setupUI()
    }
    
    private func setupNavigationBar() {
        navigationController?.configureNavigationBar(leftButton: backButton, rightButton: saveButton, target: self)
    }
    
    private func setupUI() {
        view.backgroundColor = .appColor
        addSubviews()
        configureCollectionView()
        configureCompositionalLayout()
        activateConstraints()
    }
    private func addSubviews() {
        view.addSubview(blurredImage)
        view.addSubview(contentView)
        view.addSubview(actorImage)
        contentView.addSubview(nameLabel)
        contentView.addSubview(collectionView)
        contentView.addSubview(stackView)
    }
    
    private func configureCollectionView() {
        collectionView.backgroundColor = .appColor
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
        let imageWidth = AppConstants.screenWidth / 2
        NSLayoutConstraint.activate([
            blurredImage.topAnchor.constraint(equalTo: view.topAnchor),
            blurredImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurredImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurredImage.heightAnchor.constraint(equalToConstant: AppConstants.screenWidth * AppConstants.posterImageRatio),
            
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            contentView.heightAnchor.constraint(equalToConstant: AppConstants.screenHeight * 0.6),
            
            actorImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actorImage.widthAnchor.constraint(equalToConstant: imageWidth),
            actorImage.heightAnchor.constraint(equalToConstant: imageWidth * AppConstants.posterImageRatio),
            actorImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -20),
            
            nameLabel.topAnchor.constraint(equalTo: actorImage.bottomAnchor, constant: 24),
            nameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            nameLabel.widthAnchor.constraint(equalToConstant: AppConstants.screenWidth * 0.6),
            
            collectionView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: AppConstants.posterHeight + 40),
            
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40)
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
        blurredImage.configure(image: image)
        actorImage.configure(image: image, placeholder: "placeholder")
    }
    
    private func updateLabels() {
        nameLabel.text = actor.name
        
        if let gender = actor.gender {
            stackView.addArrangedSubview(createKeyValueLabel(key: "Gender: ", value: gender))
        }
        
        if let birthday = actor.birthday {
            stackView.addArrangedSubview(createKeyValueLabel(key: "Born: ", value: birthday))
        }
        
        if let deathday = actor.deathday {
            stackView.addArrangedSubview(createKeyValueLabel(key: "Died: ", value: deathday))
        }
        
        if let country = actor.country {
            log.info(country.name)
            stackView.addArrangedSubview(createKeyValueLabel(key: "Born in:", value: country.name))
        }
        
    }
    
    private func updateShows() async {
        do {
           shows = try await castService.getCastCredit(personId: actor.id)
        } catch {
            log.error("CastDetailsVC: updateShows()")
        }
    }
    
    private func createKeyValueLabel(key: String, value: String) -> UIView {
        let container = UIView()
        
        let keyLabel = UILabel.appLabel(fontSize: 16, fontStyle: "bold")
        keyLabel.text = key
        keyLabel.textColor = .textColor
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel.appLabel(fontSize: 16, fontStyle: "regular")
        valueLabel.text = value
        valueLabel.textColor = .textColor.withAlphaComponent(0.7)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(keyLabel)
        container.addSubview(valueLabel)
        
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
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension CastDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
        navigateToDetails(for: shows[indexPath.row])
    }
    
}

extension CastDetailsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0
    }
    
}
