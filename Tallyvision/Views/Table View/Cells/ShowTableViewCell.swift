//
//  ShowTableViewCell.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 7. 1. 2025..
//

import UIKit

class ShowTableViewCell: UITableViewCell {
    
    static let identifier = String(describing: ShowTableViewCell.self)
    
    lazy var cellView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryAppColor
        view.layer.cornerRadius = 10
        return view.forAutoLayout()
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(cellView)
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
}
