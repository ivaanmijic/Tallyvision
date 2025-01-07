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
    
    
    static var darkGray: UIColor {
        getColor(red: 28, green: 28, blue: 31, alpha: 1)
    }
    
    static var lightGray: UIColor {
        getColor(red: 239, green: 239, blue: 240, alpha: 1)
    }
    
    static var appColor: UIColor {
        getColor(darkColor: .black, lightColor: .white)
    }
    
    static var textColor: UIColor {
        getColor(darkColor: .white, lightColor: .black)
    }
    
    static var secondaryAppColor: UIColor {
        getColor(darkColor: .darkGray, lightColor: .lightGray)
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
