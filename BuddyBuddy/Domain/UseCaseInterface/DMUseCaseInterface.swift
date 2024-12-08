//
//  DMUseCaseInterface.swift
//  BuddyBuddy
//
//  Created by 김성률 on 11/12/24.
//

import Foundation

import RxSwift

protocol DMUseCaseInterface {
    func fetchDMList(playgroundID: String) -> Single<Result<[DMList], Error>>
    
    func fetchDMHistory(
        playgroundID: String,
        roomID: String
    ) -> Single<Result<[DMHistory], Error>>
    
    func fetchDMHistoryForList(
        playgroundID: String,
        roomID: String
    ) -> Single<Result<[DMHistoryString], Error>>
    
    func fetchDMUnRead(
        playgroundID: String,
        roomID: String
    ) -> Single<Result<DMUnRead, Error>>
    
    func sendDM(
        playgroundID: String,
        roomID: String,
        message: String,
        files: [Data]
    ) -> Single<Result<[DMHistory], Error>>
    
    func connectSocket(roomID: String)
    
    func disConnectSocket()
    
    func observeMessage(roomID: String) -> Observable<Result<[DMHistory], Error>>
    
    func findRoomIDFromUser(userID: String) -> (String, String)
}
