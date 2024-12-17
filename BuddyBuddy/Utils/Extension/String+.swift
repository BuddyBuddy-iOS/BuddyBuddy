//
//  String+.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/6/24.
//

import Foundation
import RegexBuilder

extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized<T: CVarArg>(_ args: T...) -> String {
        let format = NSLocalizedString(self, comment: "")
        return String(format: format, arguments: args)
    }
    
    func toDate(format: BuddyDateFormatter) -> Date? {
        BuddyDateFormatter.standard.dateFormat = format.value
        return BuddyDateFormatter.standard.date(from: self)
    }
    
    func isVaild(type: RegularExpression) throws -> Bool {
        if #available(iOS 16.0, *) {
            let regex = try Regex(type.rawValue)
            return self.wholeMatch(of: regex) != nil
        } else {
            let regex = try NSRegularExpression(pattern: type.rawValue)
            let range = NSRange(location: 0, length: self.utf16.count)
            let firstMatch = regex.firstMatch(
                in: self,
                options: [],
                range: range
            )
            return firstMatch != nil
        }
    }
    
    var exceptLang: String {
        return String(self.dropLast(2))
    }
    
    var extractLang: String {
        return String(self.suffix(2))
    }
}
