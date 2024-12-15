//
//  ChannelInfo.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/28/24.
//

import Foundation

struct ChannelInfo {
    let channelID: String
    let channelName: String
    let description: String?
    let coverImage: String?
    let ownerID: String
    let channelMembers: [UserProfile]
}
