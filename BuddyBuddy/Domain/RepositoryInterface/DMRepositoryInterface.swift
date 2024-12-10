//
//  DMRepositoryInterface.swift
//  BuddyBuddy
//
//  Created by 김성률 on 11/19/24.
//

import Foundation

import RxSwift

protocol DMRepositoryInterface {
    func fetchDMList(playgroundID: String) -> Single<Result<[DMList], Error>>
    
    func fetchDMHistoryString(
        playgroundID: String,
        roomID: String
    ) -> Single<Result<[DMHistoryString], Error>>
    
    func fetchDMHistory(
        playgroundID: String,
        roomID: String
    ) -> RxSwift.Single<Result<[DMHistory], Error>>
    
    func fetchDMUnread(
        playgroundID: String,
        roomID: String
    ) -> Single<Result<DMUnRead, Error>>
    
    func sendDM(
        playgroundID: String,
        roomID: String,
        message: String,
        files: [Data]
    ) -> Single<Result<DMHistoryString, Error>>
    
    func convertArrayToDMHistory(
        roomID: String,
        dmHistoryStringArray: [DMHistoryString]
    ) -> Single<Result<[DMHistory], Error>>
    
    func convertObjectToDMHistory(
        roomID: String,
        dmHistoryString: DMHistoryString
    ) -> Single<Result<DMHistory, Error>> 
    
    func fetchDMHistoryTable(roomID: String) -> Single<Result<[DMHistory], Error>>
    
    func findRoomIDFromUser(userID: String) -> (String, String)
}
