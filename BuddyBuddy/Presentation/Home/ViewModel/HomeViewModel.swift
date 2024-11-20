//
//  HomeViewModel.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/6/24.
//

import Foundation

import RxCocoa
import RxSwift

struct Playground {
    let id: String
    let title: String
}

final class HomeViewModel: ViewModelType {
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let coordinator: HomeCoordinator
    private let channelUseCase: ChannelUseCaseInterface
    private let playground: Playground
    
    init(
        coordinator: HomeCoordinator,
        channelUseCase: ChannelUseCaseInterface
    ) {
        self.coordinator = coordinator
        self.channelUseCase = channelUseCase
        self.playground = Playground(
            id: "70b565b8-9ca1-483f-b812-15d3e57b5cf4",
            title: "Ted Study"
        )
    }
    
    struct Input {
        let viewWillAppearTrigger: Observable<Void>
        let configureChannelCell: Observable<MyChannel>
        let menuBtnDidTap: Observable<Void>
        let channelItemDidSelected: Observable<IndexPath>
        let addMemeberBtnDidTap: Observable<Void>
        let floatingBtnDidTap: Observable<Void>
    }
    
    struct Output {
        let navigationTitle: Driver<String>
        let updateChannelState: Driver<[ChannelSectionModel]>
    }
    
    func transform(input: Input) -> Output {
        let navigationTitle = PublishRelay<String>()
        let updateChannelState = PublishRelay<[ChannelSectionModel]>()
        let channelList = BehaviorRelay<MyChannelList>(value: [])
        
        input.viewWillAppearTrigger
            .bind(with: self) { owner, _ in
                navigationTitle.accept(owner.playground.title)
            }
            .disposed(by: disposeBag)
        
        input.viewWillAppearTrigger
            .flatMap { [weak self] _ -> Single<Result<MyChannelList, any Error>> in
                // TODO: faliure 반환하며 early exit
                guard let self else { return Single.just(.success([])) }
                return channelUseCase.fetchMyChannelList(playgroundID: playground.id)
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    channelList.accept(value)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        channelList
            .bind(with: self) { owner, list in
                let isFold = false
                let titleItem = ChannelItem.title(isFold ? .caret : .arrow)
                let listItem = isFold ? [] : list.map { ChannelItem.channel($0) }
                let addItem = isFold ? [] : [ChannelItem.add("Add Channel".localized())]
                
                updateChannelState.accept([.title(item: titleItem),
                                           .list(items: listItem),
                                           .add(items: addItem)])
            }
            .disposed(by: disposeBag)
        
        input.configureChannelCell
            .flatMap { [weak self] channel -> Single<Result<UnreadCountOfChannel, any Error>> in
                // TODO: faliure 반환하며 early exit
                guard let self else {
                    return Single.just(.success(UnreadCountOfChannel(
                        channelID: "",
                        name: "",
                        count: 0
                    )))
                }
                return channelUseCase.fetchUnreadCountOfChannel(
                    playgroundID: playground.id,
                    channelID: channel.channelID,
                    after: nil
                )
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
//                    var list = unreadCountList.value
//                    list.append(value)
//                    unreadCountList.accept(list)
                    var channels = channelList.value
                    var current = channels.filter { $0.channelID == value.channelID }
                    current[0].unreadCount = value.count
                    if let index = channels.firstIndex(where: { $0.channelID == value.channelID }) {
                        channels[index] = current[0]
                        channelList.accept(channels)
                     }
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.menuBtnDidTap
            .bind(with: self) { owner, _ in
                // TODO: 화면전환
            }
            .disposed(by: disposeBag)
        
        input.channelItemDidSelected
            .bind(with: self) { owner, indexPath in
                // TODO: 화면전환
            }
            .disposed(by: disposeBag)
        
        input.addMemeberBtnDidTap
            .bind(with: self) { owner, _ in
                // TODO: 화면전환
            }
            .disposed(by: disposeBag)
        
        input.floatingBtnDidTap
            .bind(with: self) { owner, _ in
                // TODO: 화면전환
            }
            .disposed(by: disposeBag)
        
        return Output(
            navigationTitle: navigationTitle.asDriver(onErrorJustReturn: "Buddy Buddy"),
            updateChannelState: updateChannelState.asDriver(onErrorDriveWith: .empty())
        )
    }
}

