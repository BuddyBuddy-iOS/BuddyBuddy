//
//  HomeViewModel.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/6/24.
//

import Foundation

import RxCocoa
import RxSwift

final class HomeViewModel: ViewModelType {
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let coordinator: HomeCoordinator
    private let channelUseCase: ChannelUseCaseInterface
    private let playgroundUseCase: PlaygroundUseCaseInterface
    private let channelList = BehaviorRelay<MyChannelList>(value: [])
    private let navigationTitle = PublishRelay<String>()
    private let showToastMessage = PublishRelay<String>()
    
    init(
        coordinator: HomeCoordinator,
        channelUseCase: ChannelUseCaseInterface,
        playgroundUseCase: PlaygroundUseCaseInterface
    ) {
        self.coordinator = coordinator
        self.channelUseCase = channelUseCase
        self.playgroundUseCase = playgroundUseCase
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
        let showToastMessage: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let updateChannelState = BehaviorRelay<[ChannelSectionModel]>(value: [])
        let isChannelFold = BehaviorRelay(value: false)
        
        input.viewWillAppearTrigger
            .withUnretained(self)
            .flatMap { (owner, _) in
                owner.playgroundUseCase.fetchCurrentPlayground()
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    owner.navigationTitle.accept(value.name)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.viewWillAppearTrigger
            .flatMap { [weak self] _ -> Single<Result<MyChannelList, any Error>> in
                // TODO: faliure 반환하며 early exit
                guard let self else { return Single.just(.success([])) }
                return channelUseCase.fetchMyChannelList(playgroundID: UserDefaultsManager.playgroundID)
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    owner.channelList.accept(value)
                    print("🌞")
                case .failure(let error):
                    print(error)
                }
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
                    playgroundID: UserDefaultsManager.playgroundID,
                    channelID: channel.channelID,
                    after: nil
                )
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    var channels = owner.channelList.value
                    var current = channels.filter { $0.channelID == value.channelID }
                    current[0].unreadCount = value.count
                    
                    if let index = channels.firstIndex(where: { $0.channelID == value.channelID }),
                       channels != owner.channelList.value {
                        channels[index] = current[0]
                        owner.channelList.accept(channels)
                    }
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.menuBtnDidTap
            .bind(with: self) { owner, _ in
                owner.coordinator.toPlayground()
            }
            .disposed(by: disposeBag)
        
        input.channelItemDidSelected
            .bind(with: self) { owner, indexPath in
                switch indexPath.section {
                case 0:
                    let isFold = updateChannelState.value[2].items.isEmpty
                    isChannelFold.accept(!isFold)
                case 1:
                    owner.coordinator.toChannelDM(
                        channelID: owner.channelList.value[indexPath.row].channelID
                    )
                case 2:
                    owner.coordinator.toAddChannel()
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        input.addMemeberBtnDidTap
            .bind(with: self) { owner, _ in
                owner.coordinator.toInviteMember()
            }
            .disposed(by: disposeBag)
        
        input.floatingBtnDidTap
            .bind(with: self) { owner, _ in
                // TODO: 화면전환
            }
            .disposed(by: disposeBag)
        
        isChannelFold
            .bind(with: self) { owner, isFold in
                let titleItem = ChannelItem.title(isFold ? .caret : .arrow)
                let listItem = isFold ? [] : owner.channelList.value.map { ChannelItem.channel($0) }
                let addItem = isFold ? [] : [ChannelItem.add("Add Channel".localized())]
                
                updateChannelState.accept([.title(item: titleItem),
                                           .list(items: listItem),
                                           .add(items: addItem)])
            }
            .disposed(by: disposeBag)
        
        channelList
            .bind(with: self) { owner, list in
                let titleItem = ChannelItem.title(isChannelFold.value ? .caret : .arrow)
                let listItem = isChannelFold.value ? [] : list.map { ChannelItem.channel($0) }
                let addItem = isChannelFold.value ? [] : [ChannelItem.add("Add Channel".localized())]
                
                updateChannelState.accept([.title(item: titleItem),
                                           .list(items: listItem),
                                           .add(items: addItem)])
            }
            .disposed(by: disposeBag)
        
        return Output(
            navigationTitle: navigationTitle.asDriver(onErrorJustReturn: "Buddy Buddy"),
            updateChannelState: updateChannelState.asDriver(onErrorDriveWith: .empty()),
            showToastMessage: showToastMessage.asDriver(onErrorDriveWith: .empty())
        )
    }
}

extension HomeViewModel: ModalDelegate {
    func dismissModal(message: String?) {
        playgroundUseCase.fetchCurrentPlayground()
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let value):
                    owner.navigationTitle.accept(value.name)
                    if let message {
                        owner.showToastMessage.accept(message)
                    }
                case .failure(let error):
                    print(error)
                }
            } onFailure: { _, error in
                print(error)
            } onDisposed: { _ in
                print("disposed")
            }
            .disposed(by: disposeBag)
        
        channelUseCase.fetchMyChannelList(playgroundID: UserDefaultsManager.playgroundID)
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let value):
                    owner.channelList.accept(value)
                case .failure(let error):
                    print(error)
                }
            } onFailure: { _, error in
                print(error)
            } onDisposed: { _ in
                print("disposed")
            }
            .disposed(by: disposeBag)
    }
}
