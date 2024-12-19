//
//  DMRealmTable.swift
//  BuddyBuddy
//
//  Created by 김성률 on 11/19/24.
//

import Foundation

import RealmSwift

final class DMHistoryTable: Object {
    @Persisted(primaryKey: true) var dmID: String
    @Persisted var roomID: String
    @Persisted var content: String
    @Persisted var createdAt: String
    @Persisted var files: List<String> = List()
    @Persisted var user: UserTable?
    
    convenience init(
        dmID: String,
        roomID: String,
        content: String,
        createdAt: String,
        files: List<String>,
        user: UserTable
    ) {
        self.init()
        self.dmID = dmID
        self.roomID = roomID
        self.content = content
        self.createdAt = createdAt
        self.files = files
        self.user = user
    }
}

extension DMHistoryTable {
    func toDomain() -> DMHistory {
        return DMHistory(
            dmID: self.dmID,
            roomID: self.roomID,
            content: self.content,
            createdAt: self.createdAt,
            files: Array(self.files),
            user: user?.toDomain() ?? UserInfo(
                userID: "",
                email: "",
                nickname: "",
                profileImage: ""
            )
        )
    }
}
