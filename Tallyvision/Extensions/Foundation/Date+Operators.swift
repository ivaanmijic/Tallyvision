//
//  Date+Operators.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 2. 12. 2024..
//

import Foundation

extension Date {
    static let dayInterval: TimeInterval = 60 * 60 * 24;
    
    static func +(lhs: Date, rhs: TimeInterval) -> Date {
        return lhs.addingTimeInterval(rhs)
    }
    
    static func -(lhs: Date, rhs: TimeInterval) -> Date {
        return lhs.addingTimeInterval(-rhs)
    }
}
