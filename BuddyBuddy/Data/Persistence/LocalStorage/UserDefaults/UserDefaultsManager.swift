//
//  UserDefaultsManager.swift
//  BuddyBuddy
//
//  Created by 김성률 on 11/25/24.
//

import Foundation

enum UserDefaultsManager {
    enum Key: String {
        case playgroundID
        case userID
        case lastText
    }
    
    @BaseUserDefaults(key: Key.playgroundID.rawValue, defaultValue: Key.playgroundID.rawValue)
    static var playgroundID
    
    @BaseUserDefaults(key: Key.userID.rawValue, defaultValue: Key.userID.rawValue)
    static var userID
    
    @BaseUserDefaults(key: Key.lastText.rawValue, defaultValue: Key.lastText.rawValue)
    static var lastText
}
