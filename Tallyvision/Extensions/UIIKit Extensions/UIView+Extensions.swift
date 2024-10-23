//
//  UIView+Extensions.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 23. 10. 2024..
//

import UIKit

extension UIView {
    
    /// Creates view with the size of the device's screen. These views are used for UIViewController backgrounds.
    static func screen() -> UIView {
        return UIView(frame: UIScreen.main.bounds)
    }
    
    func forAutoLayout() -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    func pin(to view: UIView) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
    }
}
