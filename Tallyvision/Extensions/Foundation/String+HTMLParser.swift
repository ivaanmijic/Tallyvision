//
//  String+HTMLParser.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 13. 11. 2024..
//

import Foundation
import UIKit

extension String {
    
    func parseHTMLString() -> String? {
        guard let data = self.data(using: .utf8) else { return nil }
        
        do {
            let attributedString = try NSMutableAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil)
            
            return attributedString.string
        } catch {
            log.error("Failed to parse HTML: \(error)")
            return nil
        }
    }
    
}
