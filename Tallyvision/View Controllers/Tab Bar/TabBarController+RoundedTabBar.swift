//
//  TabBarController+RoundedTabBar.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 17. 12. 2024..
//

import UIKit

extension TabBarController {
    func configureRoundedTabBar() {
        let blurEffect = UIBlurEffect(style: .prominent)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = CGRect(x: 15, y: tabBar.bounds.minY + 5, width: tabBar.bounds.width - 30, height: tabBar.bounds.height + 20)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(
            roundedRect: blurEffectView.bounds,
            cornerRadius: (tabBar.frame.height / 2)
        ).cgPath
        blurEffectView.layer.mask = maskLayer
        
        tabBar.addSubview(blurEffectView)
        tabBar.sendSubviewToBack(blurEffectView)
        
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = UIBezierPath(
            roundedRect: CGRect(
                x: 30,
                y: tabBar.bounds.minY + 5,
                width: tabBar.bounds.width - 60,
                height: tabBar.bounds.height + 10
            ),
            cornerRadius: (tabBar.frame.height / 2)
        ).cgPath
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.opacity = 1.0
        backgroundLayer.masksToBounds = false
        tabBar.layer.insertSublayer(backgroundLayer, at: 0)
        adjustItemsSizeAndPos()
    }
    
    private func adjustItemsSizeAndPos() {
        if let items = tabBar.items {
            items.forEach { item in
                item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -40, right: 0)
            }
        }
        
        tabBar.itemWidth = 40.0
        tabBar.itemPositioning = .centered
    }
}
