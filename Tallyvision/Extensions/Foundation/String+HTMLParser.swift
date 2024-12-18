//
//  String+HTMLParser.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 13. 11. 2024..
//

import Foundation
import UIKit

extension String {
    
    func stripHTML() -> String {
        return replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
}
