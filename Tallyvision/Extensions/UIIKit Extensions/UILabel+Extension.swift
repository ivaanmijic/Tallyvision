//
//  UILabel+Extension.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 23. 10. 2024..
//

import UIKit

extension UILabel {
    
    static func screenTitle(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .textColor
        label.font = UIFont(name: "Montserrat-Bold", size: 48)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }
   
    static func subtitle(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont(name: "Montserrat-Bold", size: 24)
        label.textColor = .textColor
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }
    
    static func paragraph(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont(name: "Montserrat-Regular", size: 16)
        label.textColor = .textColor
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }
    
}
