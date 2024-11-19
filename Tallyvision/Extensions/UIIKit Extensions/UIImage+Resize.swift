//
//  UIImage+Extensions.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 23. 10. 2024..
//

import UIKit

extension UIImage {
    func resizeTo(maxWidth width: CGFloat, maxHeight height: CGFloat) -> UIImage? {
        let size = self.size
        
        let widthRatio = width / size.width
        let heightRatio = height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
