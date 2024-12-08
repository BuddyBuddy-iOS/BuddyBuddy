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
    
    func fetchDMList(playgroundID: String) -> RxSwift.Single<Result<[DMList], Error>> {
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
    
    func fetchDMHistoryString(
        playgroundID: String,
        roomID: String
    ) -> RxSwift.Single<Result<[DMHistoryString], Error>> {
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
    ) -> Single<Result<DMHistoryString, Error>> {
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
                return .success(dto.toDomain())
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    func convertArrayToDMHistory(
        roomID: String,
        dmHistoryStringArray: [DMHistoryString]
    ) -> Single<Result<[DMHistory], Error>> {
        let dmHistoryTasks = dmHistoryStringArray.map { dmHistoryString in
            Single.zip(dmHistoryString.files.map { filePath in
                self.networkService.downloadImage(router: DMRouter.dmImage(path: filePath))
            })
            .map { results -> [Data] in
                let fileDataArray = results.compactMap { result in
                    switch result {
                    case .success(let value):
                        return value
                    case .failure(let error):
                        print(error)
                        return nil
                    }
                }
                return fileDataArray
            }
            .map { [weak self] fileDataResult -> DMHistoryTable in
                let list = List<Data>()
                list.append(objectsIn: fileDataResult)
                
                let dmHistoryTable = DMHistoryTable(
                    dmID: dmHistoryString.dmID,
                    roomID: dmHistoryString.roomID,
                    content: dmHistoryString.content,
                    createdAt: dmHistoryString.createdAt,
                    files: list,
                    user: UserTable(
                        userID: dmHistoryString.user.userID,
                        email: dmHistoryString.user.email,
                        nickname: dmHistoryString.user.nickname,
                        profileImage: dmHistoryString.user.profileImage ?? ""
                    )
                )
                self?.realmRepository.updateItem(dmHistoryTable)
                return dmHistoryTable
            }
        }
        return Single.zip(dmHistoryTasks)
            .map { dmHistoryTables in
                let histories = dmHistoryTables.map { table in
                    table.toDomain()
                }
                return .success(histories)
            }
            .catch { error in
                return .just(.failure(error))
            }
    }
    
    func convertObjectToDMHistory(
        roomID: String,
        dmHistoryString: DMHistoryString
    ) -> Single<Result<DMHistory, any Error>> {
        Single.zip(dmHistoryString.files.map { filePath in
            self.networkService.downloadImage(router: DMRouter.dmImage(path: filePath))
        })
        .map { results -> [Data] in
            let fileDataArray = results.compactMap { result in
                switch result {
                case .success(let value):
                    return value
                case .failure(let error):
                    print(error)
                    return nil
                }
            }
            return fileDataArray
        }
        .map { [weak self] fileDataResult -> DMHistory in
            let list = List<Data>()
            list.append(objectsIn: fileDataResult)
            
            let dmHistoryTable = DMHistoryTable(
                dmID: dmHistoryString.dmID,
                roomID: dmHistoryString.roomID,
                content: dmHistoryString.content,
                createdAt: dmHistoryString.createdAt,
                files: list,
                user: UserTable(
                    userID: dmHistoryString.user.userID,
                    email: dmHistoryString.user.email,
                    nickname: dmHistoryString.user.nickname,
                    profileImage: dmHistoryString.user.profileImage ?? ""
                )
            )
            self?.realmRepository.updateItem(dmHistoryTable)
            
            return dmHistoryTable.toDomain()
        }
        .map { dmhistory in
            return .success(dmhistory)
        }
        .catch { error in
            return .just(.failure(error))
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
