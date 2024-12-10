//
//  DefaultChannelRepository.swift
//  BuddyBuddy
//
//  Created by 아라 on 11/19/24.
//

import Foundation

import RealmSwift
import RxSwift

final class DefaultChannelRepository: ChannelRepositoryInterface {
    private typealias Router = ChannelRouter
    private let networkService: NetworkProtocol
    private let realmRepository: RealmRepository<ChannelHistoryTable>
    
    init(
        networkService: NetworkProtocol,
        realmRepository: RealmRepository<ChannelHistoryTable>
    ) {
        self.networkService = networkService
        self.realmRepository = realmRepository
    }
    
    func fetchMyChannelList(playgroundID: String) -> Single<Result<MyChannelList, any Error>> {
        networkService.callRequest(
            router: Router.myChannelList(playgroundID: playgroundID),
            responseType: MyChannelListResponseDTO.self
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
    
    func fetchUnreadCountOfChannel(
        playgroundID: String,
        channelID: String,
        after: String?
    ) -> Single<Result<UnreadCountOfChannel, any Error>> {
        networkService.callRequest(
            router: Router.unreadCount(
                playgroundID: playgroundID,
                channelID: channelID,
                after: after
            ),
            responseType: UnreadCountOfChannelResponseDTO.self
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
    
    func createChannel(request: AddChannelReqeustDTO) -> Single<Result<AddChannel, any Error>> {
        networkService.callRequest(
            router: Router.createChannel(request: request),
            responseType: AddChannelResponseDTO.self
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
    
    func fetchChannelChats(
        channelID: String,
        date: String?
    ) -> Single<Result<Bool, any Error>> {
        let query = ChannelChatQuery(
            cursorDate: date,
            channelID: channelID,
            playgroundID: UserDefaultsManager.playgroundID
        )
        return networkService.callRequest(
            router: Router.fetchChannelChat(query: query),
            responseType: ChannelChatList.self
        )
        .map { result in
            switch result {
            case .success(_):
                return .success(true)
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    func fetchSpecificChannel(channelID: String) -> Single<Result<ChannelInfo, Error>> {
        return networkService.callRequest(
            router: Router.specificChannel(channelID: channelID),
            responseType: SpecificChannelResponseDTO.self
        )
        .map { result in
            switch result {
            case .success(let value):
                return .success(value.toDomain())
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    func changeChannelAdmin(
        channelID: String,
        selectedUserID: String
    ) -> Single<Result<Bool, Error>> {
        return networkService.callRequest(
            router: Router.changeChannelAdmin(
                channelID: channelID,
                ownerID: selectedUserID
            ),
            responseType: MyChannelDTO.self
        )
        .map { result in
            switch result {
            case .success(_):
                return .success(true)
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    func exitChannel(channelID: String) -> Single<Result<Void, Error>> {
        return networkService.callRequest(
            router: Router.exitChannel(channelID: channelID),
            responseType: MyChannelListResponseDTO.self
        )
        .map { result in
            switch result {
            case .success(_):
                return .success(())
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    func deleteChannel(channelID: String) -> Single<Result<Void, Error>> {
        return networkService.callRequest(router: Router.deleteChannel(channelID: channelID))
            .map { result in
                switch result {
                case .success(_):
                    return .success(())
                case .failure(let error):
                    return .failure(error)
                }
            }
    }
    
    func fetchChannelHistoryString(
        playgroundID: String,
        channelID: String
    ) -> Single<Result<[ChannelHistoryString], Error>> {
        let chatHistory = realmRepository.readAllItem().filter {
            $0.channelID == channelID
        }
        return networkService.callRequest(
            router: ChannelRouter.channelHistory(
                playgroundID: playgroundID,
                channelID: channelID,
                cursurDate: chatHistory.last?.createdAt ?? ""
            ),
            responseType: [ChannelHistoryResponseDTO].self
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
    
    func sendChannelChat(
        playgroundID: String,
        channelID: String,
        message: String,
        files: [Data]
    ) -> Single<Result<ChannelHistoryString, Error>> {
        return networkService.callMultiPart(
            router: ChannelRouter.sendChannelChat(
                playgroundID: playgroundID,
                channelID: channelID
            ),
            responseType: ChannelHistoryResponseDTO.self,
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
    
    func convertArrayToChannelHistory(
        channelID: String,
        channelHistoryStringArray: [ChannelHistoryString]
    ) -> Single<Result<[ChannelHistory], Error>> {
        let channelHistoryTasks = channelHistoryStringArray.map { channelHistoryString in
            Single.zip(channelHistoryString.files.map { filePath in
                self.networkService.downloadImage(
                    router: ChannelRouter.channelImage(path: filePath)
                )
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
            .map { [weak self] fileDataResult -> ChannelHistoryTable in
                let list = List<Data>()
                list.append(objectsIn: fileDataResult)
                
                let channelHistoryTable = ChannelHistoryTable(
                    channelID: channelHistoryString.channelID,
                    channelName: channelHistoryString.channelName,
                    chatID: channelHistoryString.chatID,
                    content: channelHistoryString.content,
                    createdAt: channelHistoryString.createdAt,
                    files: list,
                    user: UserTable(
                        userID: channelHistoryString.user.userID,
                        email: channelHistoryString.user.email,
                        nickname: channelHistoryString.user.nickname,
                        profileImage: channelHistoryString.user.profileImage ?? ""
                    )
                )
                self?.realmRepository.updateItem(channelHistoryTable)
                return channelHistoryTable
            }
        }
        return Single.zip(channelHistoryTasks)
            .map { channelHistoryTables in
                let histories = channelHistoryTables.map { table in
                    table.toDomain()
                }
                return .success(histories)
            }
            .catch { error in
                return .just(.failure(error))
            }
    }
    
    func convertObjectToChannelHistory(
        channelID: String,
        channelHistoryString: ChannelHistoryString
    ) -> Single<Result<ChannelHistory, any Error>> {
        Single.zip(channelHistoryString.files.map { filePath in
            self.networkService.downloadImage(router: ChannelRouter.channelImage(path: filePath))
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
        .map { [weak self] fileDataResult -> ChannelHistory in
            let list = List<Data>()
            list.append(objectsIn: fileDataResult)
            
            let channelHistoryTable = ChannelHistoryTable(
                channelID: channelHistoryString.channelID,
                channelName: channelHistoryString.channelName,
                chatID: channelHistoryString.chatID,
                content: channelHistoryString.content,
                createdAt: channelHistoryString.createdAt,
                files: list,
                user: UserTable(
                    userID: channelHistoryString.user.userID,
                    email: channelHistoryString.user.email,
                    nickname: channelHistoryString.user.nickname,
                    profileImage: channelHistoryString.user.profileImage ?? ""
                )
            )
            self?.realmRepository.updateItem(channelHistoryTable)
            
            return channelHistoryTable.toDomain()
        }
        .map { dmhistory in
            return .success(dmhistory)
        }
        .catch { error in
            return .just(.failure(error))
        }
    }
    
    func fetchChannelHistoryTable(channelID: String) -> Single<Result<[ChannelHistory], Error>> {
        return Single.create { single in
            let realmResults = self.realmRepository.readAllItem()
                .filter { $0.channelID == channelID }
                .sorted { $0.createdAt < $1.createdAt }

            let histories = realmResults.map { table in
                table.toDomain()
            }

            single(.success(.success(histories)))
            return Disposables.create()
        }
    }
}
