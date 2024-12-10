//
//  DMViewModel.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/6/24.
//

import Foundation

import RxSwift
import RxCocoa

final class DMListViewModel: ViewModelType {
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let coordinator: DMCoordinator
    private let dmUseCase: DMUseCaseInterface
    
    init(
        coordinator: DMCoordinator,
        dmUseCase: DMUseCaseInterface
    ) {
        self.coordinator = coordinator
        self.dmUseCase = dmUseCase
    }
    
    struct Input {
        let viewWillAppearTrigger: Observable<Void>
        let toDMChatting: Observable<DMListInfo>
    }
    
    struct Output {
        let updateDMListTableView: Driver<[DMListInfo]>
        let viewState: Driver<DMListState>
    }
    
    func transform(input: Input) -> Output {
        let updateDMListTableView = PublishSubject<[DMListInfo]>()
        let viewState = PublishSubject<DMListState>()
        let timer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
        
        timer
            .withUnretained(self)
            .flatMapLatest { (owner, _) in
                owner.dmUseCase.fetchDMList(
                    playgroundID: UserDefaultsManager.playgroundID
                )
                .asObservable()
            }
            .flatMap { result -> Observable<[DMListInfo]> in
                switch result {
                case .success(let dmLists):
                    let dmListInfoRequests = dmLists.map { dmList in
                        Observable.zip(
                            self.dmUseCase.fetchDMHistoryForList(
                                playgroundID: UserDefaultsManager.playgroundID,
                                roomID: dmList.roomID
                            )
                            .asObservable(),
                            self.dmUseCase.fetchDMUnRead(
                                playgroundID: UserDefaultsManager.playgroundID,
                                roomID: dmList.roomID
                            )
                            .asObservable()
                        )
                        .flatMap { history, unread -> Observable<DMListInfo> in
                            switch (history, unread) {
                            case (.success(let historyArray), .success(let unreadData)):
                                return Observable.just(DMListInfo(
                                    profileImg: dmList.user.profileImage ?? "",
                                    userName: dmList.user.nickname,
                                    lastText: historyArray.last?.content ?? "",
                                    lastTime: historyArray.last?.createdAt ?? "",
                                    unReadCount: unreadData.count,
                                    roomID: dmList.roomID
                                ))
                            case (.failure(let error), _), (_, .failure(let error)):
                                return Observable.error(error)
                            }
                        }
                    }
                    return Observable.zip(dmListInfoRequests)
                case .failure(let error):
                    return Observable.error(error)
                }
            }
            .bind(with: self) { _, response in
                if response.isEmpty {
                    viewState.onNext(.emptyList)
                } else {
                    updateDMListTableView.onNext(response)
                    viewState.onNext(.chatting)
                }
            }
            .disposed(by: disposeBag)
        
        input.toDMChatting
            .bind(with: self) { owner, value in
                owner.toDMChatting(value)
            }
            .disposed(by: disposeBag)
        
        return Output(
            updateDMListTableView: updateDMListTableView.asDriver(onErrorJustReturn: []),
            viewState: viewState.asDriver(onErrorJustReturn: .emptyList)
        )
    }
 
    func toDMChatting(_ dmListInfo: DMListInfo) {
        coordinator.toDMChatting(dmListInfo)
    }
}
