//
//  HomeCoordinator.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/6/24.
//

import Foundation

protocol HomeCoordinator: Coordinator {
    func toChannelSetting(channelID: String)
    func toChannelAdmin(channelID: String)
    func toInviteMember()
    func toProfile(userID: String)
    func toChannelDM(channelID: String)
    func toAddChannel()
    func toPlayground()
    func dismissModal()
}
