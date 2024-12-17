//
//  InstanceCountHelper.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 12/16/24.
//

import Foundation

final class InstanceCountHelper {
    private static var counts: [String: Int] = [:]
    
    private static func key<T>(for type: T.Type) -> String {
        return String(describing: type)
    }

    static func increment<T>(for type: T.Type) {
        let key = key(for: type)
        counts[key, default: 0] += 1
        print("\(key)", counts[key] ?? 0, "+🩵")
    }

    static func decrement<T>(for type: T.Type) {
        let key = key(for: type)
        counts[key, default: 0] -= 1
        print("\(key)", counts[key] ?? 0, "-🩵")
    }

    static func currentCount<T>(for type: T.Type) -> Int {
        let key = key(for: type)
        return counts[key, default: 0]
    }
}
