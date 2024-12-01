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
        .flatMap { response -> Single<Result<[DMHistory], Error>> in
            switch response {
            case .success(let value):
                return self.dmRepositoryInterface.convertArrayToDMHistory(
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
    
    func fetchDMUnRead(
        playgroundID: String,
        roomID: String,
        after: String
    ) -> Single<Result<DMUnRead, Error>> {
        return dmRepositoryInterface.fetchDMNoRead(
            playgroundID: playgroundID,
            roomID: roomID,
            after: after
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
        .flatMap { response -> Single<Result<[DMHistory], Error>> in
            switch response {
            case .success(let value):
                return self.dmRepositoryInterface.convertObjectToDMHistory(
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
        socketRepositoryInterface.connectSocket(roomID: roomID)
    }
    
    func disConnectSocket() {
        socketRepositoryInterface.disConnectSocket()
    }

    func observeMessage(roomID: String) -> Observable<Result<[DMHistory], Error>> {
        return self.socketRepositoryInterface.observeMessage()
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
}
