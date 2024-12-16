//
//  SearchImageType.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/12/24.
//

import Foundation

enum SearchImageType {
    case channel
    case country(emoji: Country)
    
    var toImgTitle: String {
        switch self {
        case .channel:
            return "unread"
        case .country(let emoji):
            return emoji.toString
        }
    }
}

enum Country: String, CaseIterable {
    case kr
    case us
    case jp
    case cn
    case es
    case fr
    case pt
    case ind
    case sg
    case au

    var toString: String {
        switch self {
        case .kr: 
            return "KoreaFlag"
        case .us:
            return "USAFlag"
        case .jp:
            return "JapanFlag"
        case .cn:
            return "ChinaFlag"
        case .es:
            return "SpainFlag"
        case .fr:
            return "FranceFlag"
        case .pt:
            return "PortugalFlag"
        case .ind:
            return "IndiaFlag"
        case .sg:
            return "SingaporeFlag"
        case .au:
            return "AustraliaFlag"
        }
    }
    
    var toLang: String {
        switch self {
        case .kr:
            return "KO"
        case .us:
            return "EN"
        case .jp:
            return "JP"
        case .cn:
            return "ZH"
        case .es:
            return "ES"
        case .fr:
            return "FR"
        case .pt:
            return "PT"
        case .ind:
            return "ID"
        case .sg:
            return "EN"
        case .au:
            return "EN"
        }
    }
}
