//
//  DefaultUserRepository.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/21/24.
//

import Foundation

import RxCocoa
import RxSwift

final class DefaultUserRepository: UserRepositoryInterface {
    private let networkService: NetworkProtocol
    
    init(networkService: NetworkProtocol) {
        self.networkService = networkService
    }
    
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
    
    func getUserProfileImage(imagePath: String?) -> Single<Result<Data?, Error>> {
        guard let imagePath else { return Single.just(.success(nil)) }
        let router = UserRouter.userProfileImage(path: imagePath)
        return networkService.downloadImage(router: router)
            .map { result in
                switch result {
                case .success(let data):
                    return .success(data)
                case .failure(let error):
                    return .failure(error)
                }
            }
    }
    
    func loginWithApple(query: AppleLoginQuery) -> Single<Result<Bool, Error>> {
        return networkService.callRequest(
            router: UserRouter.appleLogin(query: query),
            responseType: LogInDTO.self
        )
        .map { result in
            switch result {
            case .success(let value):
                KeyChainManager.shared.saveAccessToken(value.token.accessToken)
                KeyChainManager.shared.saveRefreshToken(value.token.refreshToken)
                return .success(true)
            case .failure(_):
                return .success(false)
            }
        }
    }
    
    func loginWithEmail() -> Single<Result<Bool, Error>> {
        let login = LoginQuery(
            email: "casadepapel@gmail.com",
            password: "1q2w3e4rQ!"
        )
        
        return networkService.callRequest(
            router: UserRouter.emailLogin(query: login),
            responseType: LogInDTO.self
        )
        .map { result in
            switch result {
            case .success(let value):
                KeyChainManager.shared.saveAccessToken(value.token.accessToken)
                KeyChainManager.shared.saveRefreshToken(value.token.refreshToken)
                UserDefaultsManager.userID = value.userID
                return .success(true)
            case .failure(let error):
                print(error)
                return .success(false)
            }
        }
    }
}
