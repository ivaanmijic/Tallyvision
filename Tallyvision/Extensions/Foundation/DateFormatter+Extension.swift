//
//  DateFormatter+Extension.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 27. 11. 2024..
//

import Foundation

extension DateFormatter {
    
    static var apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static func dayAndMont(fromDate date: Date) -> (day: Int, monthName: String) {
        let day = Calendar.current.component(.day, from: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let monthName = formatter.string(from: date)
        return (day, monthName)
    }
}
