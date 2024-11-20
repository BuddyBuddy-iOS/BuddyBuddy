//
//  UserRepository.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/21/24.
//

import Foundation

import RxCocoa
import RxSwift

final class UserRepository: UserRepositoryInterface {
    @Dependency(NetworkProtocol.self) private var networkService
//    private let networkService: NetworkProtocol
//    
//    init(networkService: NetworkProtocol) {
//        self.networkService = networkService
//    }
    
    func checkMyProfile() -> Single<Result<MyProfile, Error>> {
        let router = UserRouter.myProfile
        return networkService.callRequest(
            router: router,
            responseType: ProfileDTO.self
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
    func checkUserProfile(userID: String) -> Single<Result<UserProfile, Error>> {
        let router = UserRouter.userProfile(query: userID)
        return networkService.callRequest(
            router: router,
            responseType: UserProfileDTO.self
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
}