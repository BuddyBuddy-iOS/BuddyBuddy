//
//  BuddyDateFormatter.swift
//  BuddyBuddy
//
//  Created by 아라 on 11/19/24.
//

import Foundation

enum BuddyDateFormatter {
    static let standard = DateFormatter()
    
    case defaultDate
    case simpleDate
    case yearMonthDay
    case HourMinute
    
    var value: String {
        switch self {
        case .defaultDate:
            return "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        case .simpleDate:
            return "SimpleDate".localized()
        case .yearMonthDay:
            return "yyyy년 MM월 dd일"
        case .HourMinute:
            return "a HH:mm"
        }
    }
}
