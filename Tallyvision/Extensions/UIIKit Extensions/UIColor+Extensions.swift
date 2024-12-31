//
//  UIColor+Extensions.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 23. 10. 2024..
//

import UIKit

extension UIColor {
    
    static var baseYellow: UIColor {
       getColor(red: 255, green: 199, blue: 0, alpha: 1)
    }
    
    static var appBlack: UIColor {
        getColor(red: 2, green: 9, blue: 19, alpha: 1)
    }
    
    static var appBlue: UIColor {
        getColor(red: 17, green: 38, blue: 57, alpha: 1)
    }
    
    static var appGray: UIColor {
        getColor(red: 117, green: 117, blue: 177, alpha: 1)
    }
    
    static var screenColor: UIColor {
        getColor(darkColor: .appBlack, lightColor: .white)
    }
    
    static var textColor: UIColor {
        getColor(darkColor: .white, lightColor: .black)
    }
    
    static var secondaryScreenColor: UIColor {
        getColor(darkColor: .appBlue, lightColor: .gray)
    }
   
    static func getColor(darkColor: UIColor, lightColor: UIColor) -> UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? darkColor : lightColor
        }
    }
    
    static func getColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
}
