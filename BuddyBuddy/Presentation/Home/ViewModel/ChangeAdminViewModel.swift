//
//  ChangeAdminViewModel.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/13/24.
//

import Foundation

import RxCocoa
import RxSwift

final class ChangeAdminViewModel: ViewModelType {
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
    
    struct Input {
        let backBtnTapped: Observable<Void>
        let viewWillAppear: Observable<Void>
        let selectedUser: Observable<UserProfileData>
        let cancelBtnTapped: Observable<Void>
        let changeBtnTapped: Observable<Void>
    }
    
    struct Output {
        let channelMembers: Driver<[UserProfileData]>
        let showAlert: Driver<Bool>
        let alertContents: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let channelMembers = PublishRelay<[UserProfileData]>()
        let showAlert = BehaviorSubject<Bool>(value: false)
        let alertContents = PublishRelay<String>()
        
        var selectedUser = UserProfileData(
            userID: "",
            email: "",
            nickname: "",
            profileImage: nil
        )
        
        input.viewWillAppear
            .withUnretained(self)
            .flatMap { (owner, _) in
                owner.useCase.fetchSpecificChannel(channelID: owner.channelID)
            }
            .bind { result in
                switch result {
                case .success(let value):
                    channelMembers.accept(value.channelMembers.filter({ user in
                        user.userID != UserDefaultsManager.userID
                    }))
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.selectedUser
            .bind { user in
                selectedUser = user
                showAlert.onNext(true)
                alertContents.accept(user.nickname)
            }
            .disposed(by: disposeBag)
        
        input.cancelBtnTapped
            .bind { _ in
                showAlert.onNext(false)
            }
            .disposed(by: disposeBag)
        
        input.changeBtnTapped
            .withUnretained(self)
            .flatMap { (owner, _) in
                return owner.useCase.changeChannelAdmin(
                    channelID: owner.channelID,
                    selectedUserID: selectedUser.userID
                )
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    showAlert.onNext(!value)
                    owner.coordinator.dismissModal()
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.backBtnTapped
            .bind(with: self) { owner, _ in
                owner.coordinator.dismissModal()
            }
            .disposed(by: disposeBag)
        
        return Output(
            channelMembers: channelMembers.asDriver(onErrorJustReturn: []),
            showAlert: showAlert.asDriver(onErrorJustReturn: false),
            alertContents: alertContents.asDriver(onErrorJustReturn: "")
        )
    }
}
