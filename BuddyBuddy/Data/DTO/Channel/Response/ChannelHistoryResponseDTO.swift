//
//  ChannelHistoryResponseDTO.swift
//  BuddyBuddy
//
//  Created by 김성률 on 12/3/24.
//

import Foundation

struct ChannelHistoryResponseDTO: Decodable {
    let channelID: String
    let channelName: String
    let chatID: String
    let content: String?
    let createdAt: String
    let files: [String]
    let user: UserInfoDTO
    
    enum CodingKeys: String, CodingKey {
        case channelID = "channel_id"
        case channelName
        case chatID = "chat_id"
        case content
        case createdAt
        case files
        case user
    }
}

extension ChannelHistoryResponseDTO {
    func toDomain() -> ChannelHistory {
        return ChannelHistory(
            channelID: channelID,
            channelName: channelName,
            chatID: chatID,
            content: content ?? "",
            createdAt: createdAt,
            files: files,
            user: user.toDomain()
        )
    }
}
