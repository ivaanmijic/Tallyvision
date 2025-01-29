//
//  GridStackView.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 29. 1. 2025..
//

import UIKit

class GridStackView: UIStackView {
    
    private lazy var rowStacks: [UIStackView] = {
        return (0..<3).map { _ in createRow() }
    }()
    
    private lazy var cellViews: [UIView] = {
        return (0..<6).map { _ in createCell() }
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStackView() {
        axis = .vertical
        spacing = 24
        distribution = .fillEqually
        alignment = .fill
        
        rowStacks.forEach { addArrangedSubview($0) }
        
        for (index, rowStack) in rowStacks.enumerated() {
            for i in 0..<2 {
                let cellIndex = i + index * 2
                rowStack.addArrangedSubview(cellViews[cellIndex])
            }
        }
    }
    
    private func createRow() -> UIStackView {
        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 24
        rowStack.distribution = .fillEqually
        rowStack.alignment = .fill
        return rowStack.forAutoLayout()
    }
    
    private func createCells() -> [UIView] {
        return (0..<6).map { _ in createCell() }
    }
    
    private func createCell() -> UIView {
        let containerView: UIView = {
            let view = UIView()
            view.backgroundColor = .secondaryAppColor
            view.layer.cornerRadius = 20
            view.layer.masksToBounds = true
            return view.forAutoLayout()
        }()
        
        let verticalStack: UIStackView = {
            let stack = UIStackView()
            stack.axis = .vertical
            stack.spacing = 5
            stack.alignment = .center
            stack.distribution = .equalSpacing
            return stack.forAutoLayout()
        }()
        
        let titleLabel: UILabel = {
            let label = UILabel.appLabel(fontSize: 16, fontStyle: "Bold")
            label.text = "Title"
            label.tag = 100
            label.textAlignment = .center
            return label.forAutoLayout()
        }()
        
        let subtitleLabel: UILabel = {
            let label = UILabel.appLabel(fontSize: 18, fontStyle: "SemiBold", alpha: 0.7)
            label.text = "Subtitle"
            label.tag = 200
            label.textAlignment = .center
            return label
        }()
        
        verticalStack.addArrangedSubview(titleLabel)
        verticalStack.addArrangedSubview(subtitleLabel)
        
        containerView.addSubview(verticalStack)
        
        NSLayoutConstraint.activate([
            verticalStack.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            verticalStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            verticalStack.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.8)
        ])
        
        return containerView.forAutoLayout()
    }
    
    func configureCell(at index: Int, title: String, subtitle: String) {
        guard index >= 0, index < cellViews.count else { return }
        let cell = cellViews[index]
        
        if let titleLabel = cell.viewWithTag(100) as? UILabel,
           let subtitleLabel = cell.viewWithTag(200) as? UILabel {
            titleLabel.text = title
            subtitleLabel.text = subtitle
        }
    }
}

