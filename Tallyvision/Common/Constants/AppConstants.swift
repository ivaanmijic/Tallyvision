//
//  AppConstants.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 4. 12. 2024..
//

import Foundation
import UIKit

class AppConstants {
    
    static let bacgroundImageRatio: CGFloat = 16 / 9
    static let posterImageRatio: CGFloat = 295/210
    
    static let screenHeight: CGFloat = UIScreen.main.bounds.height
    static let screenWidth: CGFloat = UIScreen.main.bounds.width
   
    static func topBarHeight(for navigationController: UINavigationController?) -> CGFloat {
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
