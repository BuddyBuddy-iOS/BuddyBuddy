//
//  UIFont+.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/8/24.
//

import UIKit

extension UIFont {
    public enum FontType: String {
        case bold = "Bold"
        case medium = "Medium"
    }
    
    static func pretendard(
        type: FontType,
        size: CGFloat
    ) -> UIFont? {
        return .init(
            name: "Pretendard-\(type.rawValue)",
            size: size
        )
    }
}

extension UIFont {
    /// bold 22
    static let title1 = UIFont.pretendard(
        type: .bold,
        size: 22
    )
    
    /// bold 14
    static let title2 = UIFont.pretendard(
        type: .bold,
        size: 14
    )
    
    /// bold 13
    static let bodyBold = UIFont.pretendard(
        type: .bold,
        size: 13
    )
    
    /// medium 13
    static let body = UIFont.pretendard(
        type: .medium,
        size: 13
    )
    
    /// medium 12
    static let caption = UIFont.pretendard(
        type: .medium,
        size: 12
    )
}
