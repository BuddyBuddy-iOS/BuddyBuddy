//
//  DefaultPlaygroundUseCase.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/19/24.
//

import Foundation

import RxCocoa
import RxSwift

final class DefaultPlaygroundUseCase: PlaygroundUseCaseInterface {
    @Dependency(PlaygroundRepositoryInterface.self)
    private var repository: PlaygroundRepositoryInterface
    @Dependency(UserRepositoryInterface.self)
    private var userRepository: UserRepositoryInterface
    
    func fetchPlaygroundInfo() -> Single<Result<[SearchResult], Error>> {
        return repository.fetchPlaygroundInfo()
            .flatMap { [weak self] result in
                guard let self else { return Single.just(.success([]))}
                
                switch result {
                case .success(let info):
                    return .just(.success(info))
                case .failure(let error):
                    return .just(.failure(error))
                }
            }
    }
    
    func searchInPlayground(text: String)
    -> Single<Result<[SearchResult], Error>> {
        return repository.searchPlaygournd(text: text)
            .flatMap { [weak self] result in
                guard let self else { return .just(.success([])) }
                
                switch result {
                case .success(let info):
                    return .just(.success(info))
                case .failure(let error):
                    return .just(.failure(error))
                }
            }
    }
    
    func fetchPlaygroundList() -> Single<Result<PlaygroundList, any Error>> {
        return repository.fetchPlaygroundList()
    }
    
    func fetchCurrentPlayground() -> Single<Result<Playground, any Error>> {
        return repository.fetchCurrentPlayground()
    }
}
