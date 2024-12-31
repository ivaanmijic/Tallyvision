//
//  UINavigationController+Extension.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 23. 12. 2024..
//

import UIKit

extension UINavigationController {
   
    func configureNavigationBar(leftButton: UIButton? = nil, rightButton: UIButton? = nil, target: Any) {
        interactivePopGestureRecognizer?.delegate = target as? UIGestureRecognizerDelegate
        navigationBar.isTranslucent = true
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
       
        if let leftButton = leftButton {
            topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        }
        
        if let rightButton = rightButton {
            topViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        }
    }
    
    
    
}
