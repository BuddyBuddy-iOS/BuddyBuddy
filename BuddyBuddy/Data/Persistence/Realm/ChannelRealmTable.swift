//
//  ChannelRealmTable.swift
//  BuddyBuddy
//
//  Created by 김성률 on 12/3/24.
//

import Foundation

import RealmSwift

final class ChannelHistoryTable: Object {
    @Persisted(primaryKey: true) var chatID: String
    @Persisted var channelName: String
    @Persisted var channelID: String
    @Persisted var content: String
    @Persisted var createdAt: String
    @Persisted var files: List<String> = List()
    @Persisted var user: UserTable?
    
    convenience init(
        channelID: String,
        channelName: String,
        chatID: String,
        content: String,
        createdAt: String,
        files: List<String>,
        user: UserTable
    ) {
        self.init()
        self.channelID = channelID
        self.channelName = channelName
        self.chatID = chatID
        self.content = content
        self.createdAt = createdAt
        self.files = files
        self.user = user
    }
}

extension ChannelHistoryTable {
    func toDomain() -> ChannelHistory {
        return ChannelHistory(
            channelID: self.channelID,
            channelName: self.channelName,
            chatID: self.chatID,
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
