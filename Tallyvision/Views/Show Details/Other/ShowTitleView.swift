//
//  ShowTitleView.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 18. 12. 2024..
//

import UIKit

class ShowTitleView: UIStackView {

    lazy var titleLabel: UILabel = .title(fontSize: 32).forAutoLayout()
    lazy var genresLabel: UILabel = .title(fontSize: 14).forAutoLayout()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        axis = .vertical
        spacing = 0
        alignment = .leading
        addArrangedSubview(genresLabel)
        addArrangedSubview(titleLabel)
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
    func configure(genres: [String]) {
        genresLabel.text = genres.prefix(3).joined(separator: ", ")
    }

}
