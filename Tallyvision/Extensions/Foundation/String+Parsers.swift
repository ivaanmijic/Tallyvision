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
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let parsedDate = formatter.date(from: self) {
            formatter.dateStyle = .medium
            return formatter.string(from: parsedDate)
        }
        return self
    }
    
}
