//
//  ChannelRouter.swift
//  BuddyBuddy
//
//  Created by 아라 on 11/19/24.
//

import Foundation

import Alamofire

enum ChannelRouter {
    case myChannelList(playgroundID: String)
    case channelMember(playgroundID: String, channelID: String)
    case unreadCount(playgroundID: String, channelID: String, after: String?)
    case createChannel(request: AddChannelReqeustDTO)
    case fetchChannelChat(query: ChannelChatQuery)
    case specificChannel(channelID: String)
    case changeChannelAdmin(channelID: String, ownerID: String)
    case deleteChannel(channelID: String)
    case exitChannel(channelID: String)
    case channelHistory(playgroundID: String, channelID: String, cursurDate: String)
    case sendChannelChat(playgroundID: String, channelID: String)
    case channelImage(path: String)
}

extension ChannelRouter: TargetType {
    var baseURL: String {
        return APIKey.baseURL + "/v1"
    }
    
    var method: HTTPMethod {
        switch self {
        case .myChannelList, .unreadCount, .fetchChannelChat, .specificChannel, 
                .exitChannel, .channelHistory, .channelImage, .channelMember:
            return .get
        case .changeChannelAdmin:
            return .put
        case .deleteChannel:
            return .delete
        case .createChannel, .sendChannelChat:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .myChannelList(let playgroundID):
            return "/workspaces/\(playgroundID)/my-channels"
        case .channelMember(let playgroundID, let channelID):
            return "/workspaces/\(playgroundID)/channels/\(channelID)/members"
        case .unreadCount(let playgroundID, let channelID, _):
            return "/workspaces/\(playgroundID)/channels/\(channelID)/unreads"
        case .createChannel:
            return "/workspaces/\(UserDefaultsManager.playgroundID)/channels"
        case .fetchChannelChat(let query):
            return "/workspaces/\(query.playgroundID)/channels/\(query.channelID)/chats"
        case .specificChannel(let channelID):
            return "/workspaces/\(UserDefaultsManager.playgroundID)/channels/\(channelID)"
        case .changeChannelAdmin(let channelID, _):
            return "/workspaces/\(UserDefaultsManager.playgroundID)/channels/\(channelID)/transfer/ownership"
        case .deleteChannel(let channelID):
            return "/workspaces/\(UserDefaultsManager.playgroundID)/channels/\(channelID)"
        case .exitChannel(let channelID):
            return "/workspaces/\(UserDefaultsManager.playgroundID)/channels/\(channelID)/exit"
        case .channelHistory(let playgroundID, let channelID, _):
            return "/workspaces/\(playgroundID)/channels/\(channelID)/chats"
        case .sendChannelChat(let playgroundID, let channelID):
            return "/workspaces/\(playgroundID)/channels/\(channelID)/chats"
        case .channelImage(let path):
            return path
        }
    }
    
    var header: [String: String] {
        switch self {
        case .myChannelList, .unreadCount, .fetchChannelChat, .specificChannel,
                .exitChannel, .deleteChannel, .channelHistory, .channelMember:
            return [
                Header.authorization.rawValue: KeyChainManager.shared.getAccessToken() ?? "",
                Header.Key.rawValue: APIKey.Key
            ]
        case .createChannel, .changeChannelAdmin:
            return [
                Header.authorization.rawValue: KeyChainManager.shared.getAccessToken() ?? "",
                Header.Key.rawValue: APIKey.Key,
                Header.contentType.rawValue: Header.json.rawValue
            ]
        case .sendChannelChat:
            return [
                Header.authorization.rawValue: KeyChainManager.shared.getAccessToken() ?? "",
                Header.Key.rawValue: APIKey.Key,
                Header.contentType.rawValue: Header.multipart.rawValue
            ]
        case .channelImage:
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
        switch self {
        case .myChannelList, .specificChannel, .createChannel,
                .changeChannelAdmin, .deleteChannel, .exitChannel, 
                .channelHistory, .sendChannelChat, .channelImage,
                .channelMember:
            return nil
        case .unreadCount(_, _, let after):
            guard let after else { return nil }
            return [URLQueryItem(name: "after", value: after)]
        case .fetchChannelChat(let query):
            return [URLQueryItem(name: "cursor_date", value: query.cursorDate)]
        }
    }
    
    var body: Data? {
        switch self {
        case .changeChannelAdmin(_, let ownerID):
            let query = ChangeChannelQuery(ownerID: ownerID)
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(query)
                return data
            } catch {
                return nil
            }
        case .createChannel(let request):
            let encoder = JSONEncoder()
            do {
                return try encoder.encode(request)
            } catch {
                print(error)
                return nil
            }
        default:
            return nil
        }
    }
}
