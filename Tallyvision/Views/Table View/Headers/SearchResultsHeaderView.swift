//
//  SearchResultsHeaderView.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 8. 1. 2025..
//

import UIKit

class SearchResultsHeaderView: UITableViewHeaderFooterView {
    
    static let reuseIdentifier = String(describing: SearchResultsHeaderView.self)
    
    lazy var titleLabel = UILabel.appLabel(fontSize: 16, fontStyle: "BOLD", alpha: 0.7).forAutoLayout()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(with title: String) {
        titleLabel.text = title
    }
    
}
