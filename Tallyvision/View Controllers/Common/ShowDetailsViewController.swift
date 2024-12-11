//
//  ShowDetailsViewController.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 3. 12. 2024..
//

import UIKit

class ShowDetailsViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Properties
    
    var show: Show? {
        didSet {
            updateImage()
        }
    }
    
    // MARK: - UI Components
    
    lazy var backButton: TransparentButton = {
        let button = TransparentButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return button
    }()
    
    lazy var backgroundImage = UIImageView().forAutoLayout()
    lazy var scrollView = UIScrollView().forAutoLayout()
    
    lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        return sv.forAutoLayout()
    }()
    
    lazy var transparentMaskView = UIView().forAutoLayout()
    lazy var contentView = UIView().forAutoLayout()
    
    lazy var contentStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        view.alignment = .top
        view.distribution = .fill
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
        view.layer.cornerRadius = 40
        view.clipsToBounds = true
        view.backgroundColor = .appBlack
        return view.forAutoLayout()
    }()
   
    lazy var horizontalInfoView = UIView().forAutoLayout()
    
    lazy var horizontalInfoStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.alignment = .leading
        return sv.forAutoLayout()
    }()
   
    lazy var ratingLabel = DecoratedLabel().forAutoLayout()
    lazy var dateLabel = DecoratedLabel().forAutoLayout()
    lazy var runtimeLabel = DecoratedLabel().forAutoLayout()
    
    lazy var titleLable: UILabel = .title(fontSize: 32).forAutoLayout()
    
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
  
    lazy var introductionView = IntroductionView().forAutoLayout()
    lazy var genresView = GenresView().forAutoLayout()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
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
        setupScrollableStackView()
        setupStackView()
        setupSaveButton()
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
   
    private func setupScrollableStackView() {
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.pin(to: view)
   
        scrollView.addSubview(stackView)
        stackView.pin(to: scrollView)
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    private func setupStackView() {
        stackView.addArrangedSubview(transparentMaskView)
        NSLayoutConstraint.activate([
            transparentMaskView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            transparentMaskView.heightAnchor.constraint(equalToConstant: AppConstants.screenHeight * 0.38),
        ])
        
        stackView.addArrangedSubview(contentView)
        setupContentView()
    }
   
    private func setupContentView() {
        contentView.addSubview(contentStackView)
        contentStackView.pin(to: contentView)
       
        contentStackView.addArrangedSubview(horizontalInfoView)
        setupHorizonatalInfoView()
        
        if let title = show?.title {
            titleLable.text = title
            contentStackView.addArrangedSubview(titleLable)
        }
        
        if let summary = show?.summary {
            contentStackView.addArrangedSubview(introductionView)
            introductionView.setText(summary)
        }
        
        if let genres = show?.genres, genres.count > 0 {
            contentStackView.addArrangedSubview(genresView)
            genresView.configure(with: genres)
        }
    }
    
   private func setupHorizonatalInfoView() {
        horizontalInfoView.addSubview(horizontalInfoStackView)
        horizontalInfoStackView.pin(to: horizontalInfoView)
        
        if let rating = show?.rating {
            ratingLabel.configure(icon: UIImage(systemName: "star.fill"), withColor: .baseYellow, text: "\(rating)")
            horizontalInfoStackView.addArrangedSubview(ratingLabel)
        }
        
        if let premiereDate = show?.premiereDate {
            var yearsString = String(premiereDate.prefix(4))
            if let endDate = show?.endDate {
                let endYearString = String(endDate.prefix(4))
                yearsString = yearsString + " - " + endYearString
            }
            dateLabel.configure(icon: UIImage(systemName: "calendar"), withColor: .purple, text: yearsString)
            horizontalInfoStackView.addArrangedSubview(dateLabel)
        }
        
        if let averageRuntime = show?.averageRuntime {
            runtimeLabel.configure(icon: UIImage(systemName: "clock.fill"), withColor: .gray, text: "\(averageRuntime) min")
            horizontalInfoStackView.addArrangedSubview(runtimeLabel)
        }
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
   
    
    // MARK: - Actions
    private func updateImage() {
        guard let imageURL = show?.image?.original, let sd_imageURL = URL(string: imageURL) else { return }
        backgroundImage.sd_setImage(with: sd_imageURL)
    }
    
    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func addToFavorites() {
        log.info("Added \(show!.title) to favorites")
    }
   
}
