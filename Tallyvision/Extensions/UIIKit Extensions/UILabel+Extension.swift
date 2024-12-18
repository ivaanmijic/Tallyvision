//
//  UILabel+Extension.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 23. 10. 2024..
//

import UIKit

extension UILabel {
    
    static func title(withText text: String = "", fontSize: CGFloat = 36) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .textColor
        label.font = UIFont(name: "RedHatDisplay-Bold", size: fontSize)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }
   
    static func paragraph() -> UILabel {
        let label = UILabel()
        label.textColor = .textColor.withAlphaComponent(0.7)
        label.font = UIFont(name: "RedHatDisplay-Regular", size: 16)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }
    
    
}
