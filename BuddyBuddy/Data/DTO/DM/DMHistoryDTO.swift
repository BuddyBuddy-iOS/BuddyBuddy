//
//  DMHistoryDTO.swift
//  BuddyBuddy
//
//  Created by 김성률 on 11/16/24.
//

import Foundation

struct DMHistoryDTO: Decodable {
    let dmID: String
    let roomID: String
    let content: String?
    let createdAt: String
    let files: [String]
    let user: UserInfoDTO
    
    enum CodingKeys: String, CodingKey {
        case dmID = "dm_id"
        case roomID = "room_id"
        case content
        case createdAt
        case files
        case user
    }
}

extension DMHistoryDTO {
    func toDomain() -> DMHistoryString {
        return DMHistoryString(
            dmID: dmID,
            roomID: roomID,
            content: content ?? "",
            createdAt: createdAt,
            files: files,
            user: user.toDomain()
        )
    }
    
    func toDomain() -> DMHistory {
        return DMHistory(
            dmID: dmID,
            roomID: roomID,
            content: content ?? "",
            createdAt: createdAt,
            files: [],
            user: user.toDomain()
        )
    }
}
