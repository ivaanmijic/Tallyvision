//
//  IntroductionLabel.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 10. 12. 2024..
//

import UIKit

class StorylineView: UIView {
   
    lazy var stackView: UIStackView = {
        let view = UIStackView() 
        view.axis = .vertical
        view.spacing = 4
        view.alignment = .top
        view.distribution = .fill
        view.clipsToBounds = true
        return view.forAutoLayout()
    }()
    
    lazy var storylineTitle: UILabel = .appLabel(withText: "Storyline", fontSize: 18).forAutoLayout()
    lazy var storyline: UILabel = .paragraph().forAutoLayout()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        stackView.addArrangedSubview(storylineTitle)
        stackView.addArrangedSubview(storyline)
        addSubview(stackView)
        stackView.pin(to: self)
    }
    
    func setText(_ text: String) {
        storyline.text = text.stripHTML()
    }
    
}
