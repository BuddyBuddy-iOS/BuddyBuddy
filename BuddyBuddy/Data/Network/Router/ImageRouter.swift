//
//  ImageRouter.swift
//  BuddyBuddy
//
//  Created by 아라 on 12/15/24.
//

import Foundation

import Alamofire

enum ImageRouter {
    case loadImage(path: String)
}

extension ImageRouter: TargetType {
    var baseURL: String {
        return APIKey.baseURL + "/v1"
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        switch self {
        case .loadImage(let path):
            return path
        }
    }
    
    var header: [String: String] {
        switch self {
        case .loadImage:
            return [
                Header.contentType.rawValue: Header.multipart.rawValue,
                Header.authorization.rawValue: KeyChainManager.shared.getRefreshToken() ?? "",
                Header.Key.rawValue: APIKey.Key
            ]
        }
    }
    
    var parameters: String? {
        return nil
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
    
    var body: Data? {
        return nil
    }
}
