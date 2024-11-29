//
//  UIColor+Extensions.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 23. 10. 2024..
//

import UIKit

extension UIColor {
    
    static var brightYellow: UIColor {
       getColor(red: 254, green: 206, blue: 47, alpha: 1)
    }
    
    static var darkScreenColor: UIColor {
        getColor(red: 7, green: 8, blue: 15, alpha: 1)
    }
    
    static var screenColor: UIColor {
        getColor(darkColor: .darkScreenColor, lightColor: .white)
    }
    
    static var textColor: UIColor {
        getColor(darkColor: .white, lightColor: .black)
    }
    
    static var titleColor: UIColor {
        getColor(darkColor: .brightYellow, lightColor: .black)
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
