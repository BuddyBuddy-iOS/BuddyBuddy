//
//  DefaultDMRepository.swift
//  BuddyBuddy
//
//  Created by 김성률 on 11/19/24.
//

import Foundation

import RealmSwift
import RxSwift

final class DefaultDMRepository: DMRepositoryInterface {
    private let networkService: NetworkProtocol
    private let realmRepository: RealmRepository<DMHistoryTable>
    
    init(
        networkService: NetworkProtocol,
        realmRepository: RealmRepository<DMHistoryTable>
    ) {
        self.networkService = networkService
        self.realmRepository = realmRepository
    }
    
    func fetchDMList(playgroundID: String) -> Single<Result<[DMList], Error>> {
        return networkService.callRequest(
            router: DMRouter.dmList(playgroundID: playgroundID),
            responseType: [DMListDTO].self
        )
        .map { result in
            switch result {
            case .success(let dto):
                return .success(dto.map { $0.toDomain() })
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    func fetchDMHistory(
        playgroundID: String,
        roomID: String
    ) -> RxSwift.Single<Result<[DMHistory], Error>> {
        let chatHistory = realmRepository.readAllItem().filter {
            $0.roomID == roomID
        }.sorted { $0.createdAt < $1.createdAt }
        return networkService.callRequest(
            router: DMRouter.dmHistory(
                playgroundID: playgroundID,
                roomID: roomID,
                cursorDate: chatHistory.last?.createdAt ?? ""
            ),
            responseType: [DMHistoryDTO].self
        )
        .map { result in
            switch result {
            case .success(let dto):
                dto.forEach {
                    self.realmRepository.updateItem($0.toTable())
                }
                return .success(dto.map { $0.toDomain() })
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    func fetchDMUnread(
        playgroundID: String,
        roomID: String
    ) -> RxSwift.Single<Result<DMUnRead, Error>> {
        let chatHistory = realmRepository.readAllItem().filter {
            $0.roomID == roomID
        }.sorted { $0.createdAt < $1.createdAt }
        return networkService.callRequest(
            router: DMRouter.dmUnRead(
                playgroundID: playgroundID,
                roomID: roomID,
                after: chatHistory.last?.createdAt ?? ""
            ),
            responseType: DMUnReadDTO.self)
        .map { result in
            switch result {
            case .success(let dto):
                return .success(dto.toDomain())
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    func sendDM(
        playgroundID: String,
        roomID: String,
        message: String,
        files: [Data]
    ) -> Single<Result<DMHistory, Error>> {
        return networkService.callMultiPart(
            router: DMRouter.dmSend(
                playgroundID: playgroundID,
                roomID: roomID
            ),
            responseType: DMHistoryDTO.self,
            content: message,
            files: files
        )
        .map { result in
            switch result {
            case .success(let dto):
                self.realmRepository.updateItem(dto.toTable())
                return .success(dto.toDomain())
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    func fetchDMHistoryTable(roomID: String) -> Single<Result<[DMHistory], Error>> {
        return Single.create { single in
            let realmResults = self.realmRepository.readAllItem().filter { $0.roomID == roomID }
                .sorted { $0.createdAt < $1.createdAt }

            let histories = realmResults.map { table in
                table.toDomain()
            }

            single(.success(.success(histories)))
            return Disposables.create()
        }
    }
    
    func findRoomIDFromUser(userID: String) -> (String, String) {
        let realmResults = self.realmRepository.readAllItem().filter { $0.user?.userID == userID }
        return (realmResults.first?.roomID ?? "", realmResults.first?.user?.nickname ?? "")
    }
}
