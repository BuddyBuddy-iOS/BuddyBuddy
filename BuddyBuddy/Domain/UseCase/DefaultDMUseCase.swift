//
//  DefaultDMUseCase.swift
//  BuddyBuddy
//
//  Created by 김성률 on 11/12/24.
//

import Foundation

import RxSwift

final class DefaultDMUseCase: DMUseCaseInterface {
    @Dependency(DMRepositoryInterface.self) private var dmRepositoryInterface
    @Dependency(SocketRepositoryInterface.self) private var socketRepositoryInterface
    
    func fetchDMList(playgroundID: String) -> RxSwift.Single<Result<[DMList], Error>> {
        return dmRepositoryInterface.fetchDMList(playgroundID: playgroundID)
    }
    
    func fetchDMHistory(
        playgroundID: String,
        roomID: String
    ) -> Single<Result<[DMHistory], Error>> {
        return dmRepositoryInterface.fetchDMHistoryString(
            playgroundID: playgroundID,
            roomID: roomID
        )
        .flatMap { [weak self] response -> Single<Result<[DMHistory], Error>> in
            guard let self else { return Single.just(.success([]))}
            switch response {
            case .success(let value):
                return dmRepositoryInterface.convertArrayToDMHistory(
                    roomID: roomID,
                    dmHistoryStringArray: value
                )
                .flatMap { _ in
                    self.dmRepositoryInterface.fetchDMHistoryTable(roomID: roomID)
                }
            case .failure(let error):
                return Single.just(.failure(error))
            }
        }
    }
    
    func fetchDMHistoryForList(
        playgroundID: String,
        roomID: String
    ) -> Single<Result<[DMHistory], Error>> {
        return dmRepositoryInterface.fetchDMHistory(
            playgroundID: playgroundID,
            roomID: roomID
        )
        .flatMap { response in
            switch response {
            case .success(let dmHistory):
                if dmHistory.isEmpty {
                    return self.dmRepositoryInterface.fetchDMHistoryTable(roomID: roomID)
                } else {
                    return Single.just(.success(dmHistory))
                }
            case .failure(let error):
                return Single.just(Result.failure(error))
            }
        }
    }
    
    func fetchDMUnRead(
        playgroundID: String,
        roomID: String
    ) -> Single<Result<DMUnRead, Error>> {
        return dmRepositoryInterface.fetchDMUnread(
            playgroundID: playgroundID,
            roomID: roomID
        )
    }
    
    func sendDM(
        playgroundID: String,
        roomID: String,
        message: String,
        files: [Data]
    ) -> Single<Result<[DMHistory], Error>> {
        return dmRepositoryInterface.sendDM(
            playgroundID: playgroundID,
            roomID: roomID, 
            message: message,
            files: files
        )
        .flatMap { [weak self] response -> Single<Result<[DMHistory], Error>> in
            guard let self else { return Single.just(.success([]))}
            switch response {
            case .success(let value):
                return dmRepositoryInterface.convertObjectToDMHistory(
                    roomID: roomID,
                    dmHistoryString: value
                )
                .flatMap { _ in
                    self.dmRepositoryInterface.fetchDMHistoryTable(roomID: roomID)
                }
            case .failure(let error):
                return Single.just(.failure(error))
            }
        }
    }
    
    func connectSocket(roomID: String) {
        socketRepositoryInterface.connectSocket(ID: roomID)
    }
    
    func disConnectSocket() {
        socketRepositoryInterface.disConnectSocket()
    }

    func observeMessage(roomID: String) -> Observable<Result<[DMHistory], Error>> {
        return self.socketRepositoryInterface.observeDMMessage()
            .flatMap { dmHistoryString in
                self.dmRepositoryInterface.convertObjectToDMHistory(
                    roomID: roomID,
                    dmHistoryString: dmHistoryString
                )
            }
            .flatMap { _ in
                self.dmRepositoryInterface.fetchDMHistoryTable(roomID: roomID)
            }
            .asObservable()
    }
    
    func findRoomIDFromUser(userID: String) -> (String, String) {
        return self.dmRepositoryInterface.findRoomIDFromUser(userID: userID)
    }
}
