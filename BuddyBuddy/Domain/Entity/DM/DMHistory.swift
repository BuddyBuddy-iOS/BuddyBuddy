//
//  DMHistoryData.swift
//  BuddyBuddy
//
//  Created by 김성률 on 11/29/24.
//

import Foundation

struct DMHistory {
    let dmID: String
    let roomID: String
    let content: String
    let createdAt: String
    let files: [String]
    let user: UserInfo
}

extension DMHistory {
    func toChatType() -> ChatType<DMHistory> {
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
