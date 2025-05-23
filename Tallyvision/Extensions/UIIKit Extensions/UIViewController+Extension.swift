//
//  UIViewController+Extension.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 23. 12. 2024..
//

import UIKit

protocol DetailNavigable {}

extension Show: DetailNavigable {}
extension Person: DetailNavigable {}

extension UIViewController {
    
    func navigateToDetails(for item: DetailNavigable) {
        var detailsVC: UIViewController!
        if let show = item as? Show {
            detailsVC = ShowViewController(show: show)
        } else if let person = item as? Person {
            detailsVC = CastViewController(actor: person)
        }
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }

}
