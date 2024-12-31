//
//  UIViewController+Extension.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 23. 12. 2024..
//

import UIKit

extension UIViewController {
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }

}
