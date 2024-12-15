//
//  DIContainer.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/7/24.
//

import Foundation

final class DIContainer {
    static var storage: [String: Any] = [:]
    static var cache: [String: Any] = [:]
    
    private init() { }
    
    static func register<T>(type: T.Type, _ object: T) {
        storage["\(type)"] = object
    }
    
    static func resolve<T>(type: T.Type) -> T {
        let key = "\(type)"
        
        if let cachedObject = cache[key] as? T {
            return cachedObject
        }
        
        InstanceCountHelper.increment(for: type)
        
        guard let object = storage[key] as? T else {
            fatalError("register되지 않은 객체 호출: \(type)")
        }
        cache[key] = object
        return object
    }
}
