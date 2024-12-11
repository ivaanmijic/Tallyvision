//
//  PaddingLabel.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 10. 12. 2024..
//

import UIKit

class PaddingLabel: UILabel {

    var textInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    
    override var intrinsicContentSize: CGSize {
        let originalConentSize = super.intrinsicContentSize
        let widht = originalConentSize.width + textInsets.left + textInsets.right
        let height = originalConentSize.height + textInsets.top + textInsets.bottom
        return CGSize(width: widht, height: height)
    }
    
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: textInsets)
        super.drawText(in: insetRect)
    }

}
