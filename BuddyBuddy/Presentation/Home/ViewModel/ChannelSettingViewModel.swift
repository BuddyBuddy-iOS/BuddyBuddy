//
//  ChannelSettingViewModel.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/13/24.
//

import Foundation

import RxCocoa
import RxSwift

final class ChannelSettingViewModel: ViewModelType {
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let coordinator: HomeCoordinator
    private let useCase: ChannelUseCaseInterface
    private let channelID: String
    
    init(
        coordinator: HomeCoordinator,
        useCase: ChannelUseCaseInterface,
        channelID: String
    ) {
        self.coordinator = coordinator
        self.useCase = useCase
        self.channelID = channelID
    }
    
    deinit {
        print("Deinit")
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let blindViewTapped: Observable<Void>
        let exitBtnTapped: Observable<Void>
        let changeAdminBtnTapped: Observable<Void>
        let cancelBtnTapped: Observable<Void>
        let exitAlertBtnTapped: Observable<Void>
    }
    struct Output {
        let channelInfo: Driver<(String, String?)>
        let channelMembers: Driver<[UserProfile]>
        let showChangeAdminBtn: Driver<Bool>
        let alertInfo: Driver<AlertLiteral>
        let showAlert: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        let channelInfo = PublishRelay<(String, String?)>()
        let channelMembers = PublishRelay<[UserProfile]>()
        let showChangeAdminBtn = PublishRelay<Bool>()
        let alertInfo = PublishRelay<AlertLiteral>()
        let showAlert = PublishRelay<Bool>()
        
        var channelOwnerID: String = ""
        
        input.viewWillAppear
            .withUnretained(self)
            .flatMap { (owner, _) in
                owner.useCase.fetchSpecificChannel(channelID: owner.channelID)
            }
            .bind { result in
                switch result {
                case .success(let value):
                    channelOwnerID = value.ownerID
                    showChangeAdminBtn.accept(value.ownerID == UserDefaultsManager.userID)
                    channelInfo.accept((value.channelName, value.description))
                    channelMembers.accept(value.channelMembers)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.exitBtnTapped
            .bind { _ in
                showAlert.accept(true)
                if channelOwnerID == UserDefaultsManager.userID {
                    alertInfo.accept(AlertLiteral.exitChannel(isMyChannel: true))
                } else {
                    alertInfo.accept(AlertLiteral.exitChannel(isMyChannel: false))
                }
            }
            .disposed(by: disposeBag)
        
        input.changeAdminBtnTapped
            .bind(with: self) { owner, _ in
                owner.coordinator.toChannelAdmin(channelID: owner.channelID)
            }
            .disposed(by: disposeBag)
        
        input.blindViewTapped
            .bind(with: self) { owner, _ in
                owner.coordinator.popVC()
            }
            .disposed(by: disposeBag)
        
        input.cancelBtnTapped
            .bind { _ in
                showAlert.accept(false)
            }
            .disposed(by: disposeBag)
        
        input.exitAlertBtnTapped
            .withUnretained(self)
            .flatMap { (owner, _) in
                if channelOwnerID == UserDefaultsManager.userID {
                    owner.useCase.deleteChannel(channelID: owner.channelID)
                } else {
                    owner.useCase.exitChannel(channelID: owner.channelID)
                }
            }
            .bind(with: self) { owner, result in
                // TODO: 홈->채널 채팅->채널 설정에서 나가기 혹은 삭제 버튼시, popVC + 채널 -> home transition
                switch result {
                case .success(_):
                    showAlert.accept(false)
                    owner.coordinator.popVC()
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(
            channelInfo: channelInfo.asDriver(onErrorJustReturn: ("", "")),
            channelMembers: channelMembers.asDriver(onErrorJustReturn: []),
            showChangeAdminBtn: showChangeAdminBtn.asDriver(onErrorJustReturn: false),
            alertInfo: alertInfo
                .asDriver(onErrorJustReturn: AlertLiteral.exitChannel(isMyChannel: false)),
            showAlert: showAlert.asDriver(onErrorJustReturn: false)
        )
    }
}
