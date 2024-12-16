//
//  ChannelUseCaseInterface.swift
//  BuddyBuddy
//
//  Created by 아라 on 11/19/24.
//

import Foundation

import RxSwift

protocol ChannelUseCaseInterface {
    func fetchMyChannelList(playgroundID: String) -> Single<Result<MyChannelList, Error>>
    func fetchUnreadCountOfChannel(
        playgroundID: String,
        channelID: String,
        after: String?
    ) -> Single<Result<UnreadCountOfChannel, Error>>
    func createChannel(request: AddChannelReqeustDTO) -> Single<Result<AddChannel, Error>>
    func fetchChannelChats(
        channelID: String,
        date: String?
    ) -> Single<Result<Bool, any Error>>
    func fetchSpecificChannel(channelID: String) -> Single<Result<ChannelInfo, Error>>
    func changeChannelAdmin(
        channelID: String,
        selectedUserID: String
    ) -> Single<Result<Bool, Error>>
    func exitChannel(channelID: String) -> Single<Result<Void, Error>>
    func deleteChannel(channelID: String) -> Single<Result<Void, Error>>
    func fetchChannelHistory(
        playgroundID: String,
        channelID: String
    ) -> Single<Result<[ChannelHistory], Error>>
    func sendChannel(
        playgroundID: String,
        channelID: String,
        message: String,
        files: [Data]
    ) -> Single<Result<[ChannelHistory], Error>>
    func connectSocket(channelID: String)
    func disConnectSocket()
    func observeMessage(channelID: String) -> Observable<Result<[ChannelHistory], Error>>
}
