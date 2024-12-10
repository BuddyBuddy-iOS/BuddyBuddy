//
//  DefaultChannelUseCase.swift
//  BuddyBuddy
//
//  Created by 아라 on 11/19/24.
//

import Foundation

import RxSwift

final class DefaultChannelUseCase: ChannelUseCaseInterface {
    @Dependency(ChannelRepositoryInterface.self)
    private var repository: ChannelRepositoryInterface

    @Dependency(SocketRepositoryInterface.self)
    private var socketRepositoryInterface
  
    @Dependency(UserRepositoryInterface.self)
    private var userRepository: UserRepositoryInterface
    
    func fetchMyChannelList(playgroundID: String) -> Single<Result<MyChannelList, any Error>> {
        repository.fetchMyChannelList(playgroundID: playgroundID)
    }

    func fetchUnreadCountOfChannel(
        playgroundID: String,
        channelID: String,
        after: String? = nil
    ) -> Single<Result<UnreadCountOfChannel, any Error>> {
        repository.fetchUnreadCountOfChannel(
            playgroundID: playgroundID,
            channelID: channelID,
            after: after
        )
    }
    
    func createChannel(request: AddChannelReqeustDTO) -> Single<Result<AddChannel, any Error>> {
        repository.createChannel(request: request)
    }
    
    func fetchChannelChats(
        channelID: String,
        date: String?
    ) -> Single<Result<Bool, any Error>> {
        return repository.fetchChannelChats(
            channelID: channelID,
            date: date
        )
    }
    
    /**
     SpecificChannelResponseDTO -> ChannelInfo -> ChannelInfoData [channel info]
            MemberDTO               UserProfile             UserProfileData [유저 info]
            string?                           string?                   data? [profileImage]
     
     1. repository의 fetchSpecificChannel를 통해 ChannelInfo 변환
     2. repository.fetchProfileImageToData(from: member.profileImage)를 통해 user profile image의 string 값을 data로 변환
     3. 모두 변환한 후 Single.zip으로 묶어 ChannelInfoData로 만들어서 반환.
     */
    func fetchSpecificChannel(channelID: String) -> Single<Result<ChannelInfoData, any Error>> {
        let emtpyReturn = ChannelInfoData(
            channelID: "",
            channelName: "",
            description: "",
            coverImage: "",
            ownerID: "",
            channelMembers: []
        )
        return repository.fetchSpecificChannel(channelID: channelID)
            .flatMap { [weak self] result in
                guard let self else { return Single.just(.success(emtpyReturn))}
                switch result {
                case .success(let channelInfo):
                    let singleProfileImage = channelInfo.channelMembers.map { member in
                        self.userRepository.getUserProfileImage(imagePath: member.profileImage)
                    }
                    
                    return Single.zip(singleProfileImage) { [weak self] profileImages in
                        guard let self else { return .success(emtpyReturn)}
                        
                        let profileImages = self.changeDataArray(imageResults: profileImages)
                        let channel = self.changedChannelData(
                            channelInfo: channelInfo,
                            profileImages: profileImages
                        )
                        
                        return .success(channel)
                    }
                case .failure(let error):
                    return .just(.failure(error))
                }
            }
    }
    
    func changeChannelAdmin(
        channelID: String,
        selectedUserID: String
    ) -> Single<Result<Bool, Error>> {
        return repository.changeChannelAdmin(
            channelID: channelID,
            selectedUserID: selectedUserID
        )
    }
    
    func deleteChannel(channelID: String) -> Single<Result<Void, any Error>> {
        return repository.deleteChannel(channelID: channelID)
    }
    func exitChannel(channelID: String) -> Single<Result<Void, any Error>> {
        return repository.exitChannel(channelID: channelID)
    }
    
    func fetchChannelHistory(
        playgroundID: String,
        channelID: String
    ) -> Single<Result<[ChannelHistory], Error>> {
        return repository.fetchChannelHistoryString(
            playgroundID: playgroundID,
            channelID: channelID
        )
        .flatMap { [weak self] response -> Single<Result<[ChannelHistory], Error>> in
            guard let self else { return Single.just(.success([])) }
            switch response {
            case .success(let value):
                return repository.convertArrayToChannelHistory(
                    channelID: channelID,
                    channelHistoryStringArray: value)
                .flatMap { _ in
                    self.repository.fetchChannelHistoryTable(channelID: channelID)
                }
            case .failure(let error):
                return Single.just(.failure(error))
            }
        }
    }
    
    func sendChannel(
        playgroundID: String,
        channelID: String,
        message: String,
        files: [Data]
    ) -> Single<Result<[ChannelHistory], Error>> {
        return repository.sendChannelChat(
            playgroundID: playgroundID,
            channelID: channelID,
            message: message,
            files: files
        )
        .flatMap { [weak self] response -> Single<Result<[ChannelHistory], Error>> in
            guard let self else { return Single.just(.success([])) }
            switch response {
            case .success(let value):
                return repository.convertObjectToChannelHistory(
                    channelID: channelID,
                    channelHistoryString: value
                )
                .flatMap { _ in
                    self.repository.fetchChannelHistoryTable(channelID: channelID)
                }
            case .failure(let error):
                return Single.just(.failure(error))
            }
        }
    }
    
    func connectSocket(channelID: String) {
        socketRepositoryInterface.connectSocket(ID: channelID)
    }
    
    func disConnectSocket() {
        socketRepositoryInterface.disConnectSocket()
    }

    func observeMessage(channelID: String) -> Observable<Result<[ChannelHistory], Error>> {
        return self.socketRepositoryInterface.observeChannelMessage()
            .flatMap { channelHistoryString in
                self.repository.convertObjectToChannelHistory(
                    channelID: channelID,
                    channelHistoryString: channelHistoryString)
            }
            .flatMap { _ in
                self.repository.fetchChannelHistoryTable(channelID: channelID)
            }
            .asObservable()
    }

    private func changeDataArray(imageResults: [Result<Data?, Error>]) -> [Data] {
        imageResults.compactMap { result in
            switch result {
            case .success(let data):
                return data
            case .failure:
                return nil
            }
        }
    }
    private func changedChannelData(
        channelInfo: ChannelInfo,
        profileImages: [Data?]
    ) -> ChannelInfoData {
        let members = zip(channelInfo.channelMembers, profileImages).map { member, imageData in
            UserProfileData(
                userID: member.userID,
                email: member.email,
                nickname: member.nickname,
                profileImage: imageData
            )
        }
        
        return ChannelInfoData(
            channelID: channelInfo.channelID,
            channelName: channelInfo.channelName,
            description: channelInfo.description,
            coverImage: channelInfo.coverImage,
            ownerID: channelInfo.ownerID,
            channelMembers: members
        )
    }
}
