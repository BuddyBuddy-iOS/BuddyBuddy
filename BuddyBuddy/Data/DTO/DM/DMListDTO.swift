//
//  DMListDTO.swift
//  BuddyBuddy
//
//  Created by 김성률 on 11/12/24.
//

import Foundation

struct DMListDTO: Decodable {
    let roomID: String
    let createdAt: String
    let user: UserInfoDTO
    
    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case createdAt
        case user
    }
}

extension DMListDTO {
    func toDomain() -> DMList {
        return DMList(roomID: roomID,
                      createdAt: createdAt,
                      user: user.toDomain())
    }
}
