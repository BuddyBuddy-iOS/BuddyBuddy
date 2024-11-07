//
//  TabKind.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/6/24.
//

import Foundation

enum TabKind: CaseIterable {
    case home, dm, search, setting
    
    var tabTitle: String {
        switch self {
        case .home:
            return "홈"
        case .dm:
            return "DM"
        case .search:
            return "검색"
        case .setting:
            return "설정"
        }
    }
    
    var selectedImg: String {
        switch self {
        case .home:
            return "selectedHomeTab"
        case .dm:
            return "selectedDMTab"
        case .search:
            return "selectedSearchTab"
        case .setting:
            return "selectedSettingTab"
        }
    }
    
    var unselectedImg: String {
        switch self {
        case .home:
            return "unselectedHomeTab"
        case .dm:
            return "unselectedDMTab"
        case .search:
            return "unselectedSearchTab"
        case .setting:
            return "unselectedSettingTab"
        }
    }
}
