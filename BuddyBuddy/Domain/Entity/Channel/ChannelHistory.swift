//
//  ChannelHistory.swift
//  BuddyBuddy
//
//  Created by 김성률 on 12/3/24.
//

import Foundation

struct ChannelHistory {
    let channelID: String
    let channelName: String
    let chatID: String
    let content: String
    let createdAt: String
    let files: [String]
    let user: UserInfo
}

extension ChannelHistory {
    func toChatType() -> ChatType<ChannelHistory> {
        if !content.isEmpty && !files.isEmpty {
            return .TextAndImage(self)
        } else if !content.isEmpty && files.isEmpty {
            return .onlyText(self)
        } else if content.isEmpty && !files.isEmpty {
            return .onlyImage(self)
        } else {
            return .onlyText(self)
        }
    }
}
