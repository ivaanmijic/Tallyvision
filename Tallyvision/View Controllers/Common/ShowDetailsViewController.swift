//
//  ShowDetailsViewController.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 3. 12. 2024..
//

import UIKit

class ShowDetailsViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    var show: Show
    var showCast = [ShowCast]()
    
    var castService: CastService!
    
    // MARK: - Constructors
    init(show: Show) {
        self.show = show
        super.init(nibName: nil, bundle: nil)
        self.updateImage()
        log.info(show.showId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    
    let cell: UICollectionViewCell = {
        let cell = UICollectionViewCell()
        cell.backgroundColor = .appBlack
        return cell
    }()
    
    lazy var backButton: TransparentButton = {
        let button = TransparentButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return button
    }()
    
    lazy var backgroundImage = UIImageView().forAutoLayout()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "mask")
        collectionView.register(
            ShowMetadataView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: ShowMetadataView.reuseIdentifier
        )
        
        return collectionView.forAutoLayout()
    }()
    
    lazy var transparentMaskView = UIView().forAutoLayout()
    
    lazy var saveButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .baseYellow
        button.setTitle("Add to List", for: .normal)
        button.setTitleColor(.appBlack, for: .normal)
        button.titleLabel?.font = UIFont(name: "RedHatDisplay-Bold", size: 18)
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(addToFavorites), for: .touchUpInside)
        return button.forAutoLayout()
    }()
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupServices()
        updateUI()
    }
    
    
    private func setupNavigationBar() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    private func setupUI() {
        view.backgroundColor = .appBlack
        setupBackgroundImage()
        configureCollectionView()
        configureCompositionalLayout()
        setupSaveButton()
    }
    
    private func setupServices() {
        castService = CastService(httpClinet: TVMazeClient())
    }
    
    // TODO: update Actors section
    private func updateUI() {
        
    }
    
    private func setupBackgroundImage() {
        view.addSubview(backgroundImage)
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.heightAnchor.constraint(equalToConstant: AppConstants.screenWidth * AppConstants.posterImageRatio)
        ])
    }
    
    private func setupSaveButton() {
        view.addSubview(saveButton)
        NSLayoutConstraint.activate([
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.widthAnchor.constraint(equalToConstant: 150),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.pin(to: view)
    }
    
    private func configureCompositionalLayout() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            switch sectionIndex {
            case 1: return AppLayouts.shared.genresSection()
            default: return AppLayouts.shared.metaDataSection()
            }
        }
        collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    
    // MARK: - Actions
    private func updateImage() {
        guard let imageURL = show.image?.original, let sd_imageURL = URL(string: imageURL) else { return }
        backgroundImage.sd_setImage(with: sd_imageURL)
    }
    
    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func addToFavorites() {
        log.info("Added \(show.title) to favorites")
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension ShowDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        default: return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        
        default:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "mask", for: indexPath)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ShowMetadataView.reuseIdentifier,
                for: indexPath
            ) as! ShowMetadataView
            footer.configure(with: show)
            return footer
        }
        return UICollectionReusableView()
    }
    
    
}
