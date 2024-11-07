//
//  Dependency.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/7/24.
//

import Foundation

@propertyWrapper
struct Dependency<T> {
    private var type: T.Type
    
    public var wrappedValue: T {
        DIContainer.resolve(type: type)
    }
    
    public init(_ type: T.Type) {
        self.type = type
    }
}
