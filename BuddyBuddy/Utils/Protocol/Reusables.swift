//
//  Reusables.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/6/24.
//

import Foundation

protocol Reusables {
    static var identifier: String { get }
}

extension Reusables {
    static var identifier: String {
        return String(describing: self)
    }
}
