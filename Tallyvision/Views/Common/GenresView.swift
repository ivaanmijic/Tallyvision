//
//  GenresView.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 10. 12. 2024..
//

import UIKit

class GenresView: UIView {
   
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 8
        view.distribution = .equalSpacing
        view.alignment = .firstBaseline
        return view.forAutoLayout()
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
    
    func configure(with genres: [String]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        var rowStackView: UIStackView?
        
        for (index, genre) in genres.enumerated() {
            if index % 3 == 0 {
                rowStackView = UIStackView()
                rowStackView?.translatesAutoresizingMaskIntoConstraints = false
                rowStackView?.axis = .horizontal
                rowStackView?.spacing = 8
                rowStackView?.alignment = .fill
                rowStackView?.distribution = .fill
                stackView.addArrangedSubview(rowStackView!)
            }
            
            let label = createGenreLabel(for: genre)
            rowStackView?.addArrangedSubview(label)
        }
    }
    
    private func createGenreLabel(for genre: String) -> PaddingLabel {
        let label = PaddingLabel()
        label.text = genre
        label.font = UIFont(name: "RedHatDisplay-Bold", size: 16)
        label.backgroundColor = .appBlue
        label.textColor = .textColor
        label.textAlignment = .center
        label.layer.cornerRadius = 18
        label.clipsToBounds = true
        
        return label.forAutoLayout()
    }

}
