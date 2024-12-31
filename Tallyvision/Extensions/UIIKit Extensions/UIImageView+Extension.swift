//
//  UIImageView+Extension.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 30. 12. 2024..
//

import GRDB
import SDWebImage

extension UIImageView {
   
    func configure(image imageURL: String?, placeholder: String? = nil) {
        if let imageURL = imageURL, let sd_imageURL = URL(string: imageURL) {
            self.sd_setImage(with: sd_imageURL)
        } else if let placeholder = placeholder {
            self.image = UIImage(named: placeholder)
        }
    }
    
}
