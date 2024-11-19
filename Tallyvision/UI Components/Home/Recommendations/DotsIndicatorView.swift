//
//  ShowCardIndicatorView.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 18. 11. 2024..
//

import UIKit

class DotsIndicatorView: UIView {
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        addSubview(stackView)
        stackView.pin(to: self)
    }

    func configureDots(count: Int) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for _ in 0..<count {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: 10).isActive = true
            dot.heightAnchor.constraint(equalTo: dot.widthAnchor).isActive = true
            dot.backgroundColor = .textColor.withAlphaComponent(0.6)
            dot.layer.cornerRadius = 5
            stackView.addArrangedSubview(dot)
        }
    }

    func highlightDot(atIndex index: Int) {
        let count = stackView.arrangedSubviews.count
        let cyclicIndex = (index % count + count) % count
        
        for (i, dot) in stackView.arrangedSubviews.enumerated() {
            dot.backgroundColor = (i == cyclicIndex) ? .textColor : .textColor.withAlphaComponent(0.6)
        }
    }
}
