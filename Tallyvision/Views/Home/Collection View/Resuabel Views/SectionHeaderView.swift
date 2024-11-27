//
//  SectionHeaderView.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 27. 11. 2024..
//

import UIKit

class SectionHeaderView: UICollectionReusableView {
    static let identifier = "SectionHeaderView"
    
    lazy var headerLabel = UILabel().forAutoLayout()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI(){
        addSubview(headerLabel)
        headerLabel.pin(to: self)
    }
    
    func configure(title: String, date: Date? = nil) {
            let attributedString = NSMutableAttributedString()
            
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Montserrat-Bold", size: 24)!,
                .foregroundColor: UIColor.textColor
            ]
            let titleAttributed = NSAttributedString(string: title, attributes: titleAttributes)
            attributedString.append(titleAttributed)
            
            if let date = date {
                attributedString.append(NSAttributedString(string: "  "))
                
                let (day, month) = DateFormatter.dayAndMont(fromDate: date)
                let dateString = "\(day) " + month
                let dateAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont(name: "Montserrat-Bold", size: 20)!,
                    .foregroundColor: UIColor.textColor.withAlphaComponent(0.7)
                ]
                let dateAttributed = NSAttributedString(string: dateString.uppercased(), attributes: dateAttributes)
                attributedString.append(dateAttributed)
            }
            
            headerLabel.attributedText = attributedString
        }
}
