//
//  AppDelegate+Register.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/8/24.
//

import Foundation

extension AppDelegate {
    /**
     의존성 주입을 위한 객체 등록 메서드
     */
    func registerDependencies() {
        let networkService: NetworkProtocol = NetworkService()
        let socketService: SocketProtocol = SocketService()
        
        DIContainer.register(
            type: DMRepositoryInterface.self,
            DefaultDMRepository(
                networkService: networkService,
                realmRepository: RealmRepository<DMHistoryTable>()
            )
        )
        
        DIContainer.register(
            type: SocketRepositoryInterface.self,
            DefaultSocketRepository(
                socketService: socketService,
                realmRepository: RealmRepository<DMHistoryTable>()
            )
        )
      
        DIContainer.register(
            type: PlaygroundRepositoryInterface.self,
            DefaultPlaygroundRepository(networkService: networkService)
        )
        
        DIContainer.register(
            type: PlaygroundUseCaseInterface.self,
            DefaultPlaygroundUseCase()
        )
        
        DIContainer.register(
            type: UserRepositoryInterface.self,
            DefaultUserRepository(networkService: networkService)
        )
        
        DIContainer.register(
            type: ChannelRepositoryInterface.self,
            DefaultChannelRepository(
                networkService: networkService,
                realmRepository: RealmRepository<ChannelHistoryTable>()
            )
        )
        
        DIContainer.register(
            type: ChannelUseCaseInterface.self,
            DefaultChannelUseCase()
        )
    }
}
