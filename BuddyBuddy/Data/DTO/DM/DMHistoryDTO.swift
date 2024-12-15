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
    func toTable() -> DMHistoryTable {
        let table = DMHistoryTable()
        table.dmID = self.dmID
        table.roomID = self.roomID
        table.content = self.content ?? ""
        table.createdAt = self.createdAt
        table.files.append(objectsIn: self.files)
        table.user = self.user.toTable()
        return table
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
