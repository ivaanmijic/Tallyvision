//
//  UIViewController+Extensions.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 20. 11. 2024..
//

import UIKit

extension UIViewController {
   
    var topBarHeight: CGFloat {
        let statusBarHeight: CGFloat = {
            if #available(iOS 13.0, *) {
                return UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first?.statusBarManager?.statusBarFrame.height ?? 0
            } else {
                return UIApplication.shared.statusBarFrame.height
            }
        }()
        
        let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
        
        return statusBarHeight + navigationBarHeight
    }
    
}
