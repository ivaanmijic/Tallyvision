//
//  EpisodesViewController.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 11. 1. 2025..
//

import UIKit

class EpisodesViewController: UIViewController {
    
    lazy var titleLabel = UILabel.appLabel(withText: "Episodes", fontSize: 32).forAutoLayout()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont(name: "RedHatDisplay-SemiBold", size: 18)
        button.setTitleColor(.baseYellow, for: .normal)
        button.setTitle("Cancel", for: .normal)
        button.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        return button.forAutoLayout()
    }()
   
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .appColor
        tableView.separatorStyle = .none
        tableView.register(EpisodesTableViewCell.self, forCellReuseIdentifier: EpisodesTableViewCell.identifier)
        return tableView.forAutoLayout()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
    }
    
    private func setupNavigationBar() {
        navigationController?.configureNavigationBar(rightButton: dismissButton, target: self, isTrancluent: false)
        navigationController?.navigationBar.backgroundColor = .appColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
    }
    
    private func setupUI() {
        view.backgroundColor = .blue
        view.addSubview(tableView)
        tableView.pin(to: view)
        tableView.delegate = self
        tableView.dataSource = self
    }
    

    // MARK: - Actions
    @objc private func dismissController() {
        dismiss(animated: true)
    }
}

extension EpisodesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EpisodesTableViewCell.identifier)
                as? EpisodesTableViewCell else {
            return UITableViewCell()
        }
        return cell
    }
}
