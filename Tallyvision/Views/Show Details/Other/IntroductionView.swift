//
//  IntroductionLabel.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 10. 12. 2024..
//

import UIKit

class IntroductionView: UIView {
   
    lazy var stackView: UIStackView = {
        let view = UIStackView() 
        view.axis = .vertical
        view.spacing = 4
        view.alignment = .top
        view.distribution = .fill
        view.clipsToBounds = true
        return view.forAutoLayout()
    }()
    
    lazy var introductionTitle: UILabel = .appLabel(withText: "Introduction", fontSize: 16).forAutoLayout()
    lazy var introduction: UILabel = .paragraph().forAutoLayout()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        stackView.addArrangedSubview(introductionTitle)
        stackView.addArrangedSubview(introduction)
        addSubview(stackView)
        stackView.pin(to: self)
    }
    
    func setText(_ text: String) {
        introduction.text = text.stripHTML()
    }
    
}
