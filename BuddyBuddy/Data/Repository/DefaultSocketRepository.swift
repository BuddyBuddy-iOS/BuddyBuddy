//
//  DefaultSocketRepository.swift
//  BuddyBuddy
//
//  Created by 김성률 on 11/20/24.
//

import Foundation

import RxSwift

final class DefaultSocketRepository: SocketRepositoryInterface {
    private let socketService: SocketProtocol
    private let realmRepository: RealmRepository<DMHistoryTable>
    
    init(
        socketService: SocketProtocol,
        realmRepository: RealmRepository<DMHistoryTable>
    ) {
        self.socketService = socketService
        self.realmRepository = realmRepository
    }
    
    func connectSocket(ID: String) {
        socketService.updateURL(ID: ID)
        socketService.establishConnection()
    }
    
    func disConnectSocket() {
        socketService.closeConnection()
    }
    
    func observeDMMessage() -> Observable<DMHistory> {
        socketService.observeDMMessage()
            .map { message in
                message.toDomain()
            }
            .asObservable()
    }
    
    func observeChannelMessage() -> Observable<ChannelHistory> {
        socketService.observeChannelMessage()
            .map { message in
                message.toDomain()
            }
            .asObservable()
    }
}
