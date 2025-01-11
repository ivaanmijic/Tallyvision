//
//  EpisodesViewController.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 11. 1. 2025..
//

import UIKit

class EpisodesViewController: UIViewController {

    lazy var dismissButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont(name: "RedHatDisplay-SemiBold", size: 18)
        button.setTitleColor(.baseYellow, for: .normal)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        return button.forAutoLayout()
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
    }
    
    private func setupNavigationBar() {
        if let nav = navigationController {
            nav.configureNavigationBar(rightButton: dismissButton, target: self)
            log.debug("tu sam")
        } else {
            log.debug("nisam tu")
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .appColor
    }
    

    // MARK: - Actions
    @objc private func dismissController() {
        dismiss(animated: true)
    }
}
