//
//  BackgroundSupplementaryView.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 18. 12. 2024..
//

import UIKit

class BackgroundSupplementaryView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .appBlack
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(code:) has not been implemented")
    }
}
