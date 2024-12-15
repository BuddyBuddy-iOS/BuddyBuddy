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
    
    /*
     Cell Tap - 관리자 변경 trigger -> output alert 표출 -> 화면 dismiss
     */
    struct Input {
        let backBtnTapped: Observable<Void>
        let viewWillAppear: Observable<Void>
        let selectedUser: Observable<UserProfile>
        let cancelBtnTapped: Observable<Void>
        let changeBtnTapped: Observable<Void>
    }
    
    struct Output {
        let channelMembers: Driver<[UserProfile]>
        let showAlert: Driver<Bool>
        let alertContents: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let channelMembers = PublishRelay<[UserProfile]>()
        let showAlert = PublishRelay<Bool>()
        let alertContents = PublishRelay<String>()
        
        var selectedUser = UserProfile(
            userID: "",
            email: "",
            nickname: "",
            profileImage: ""
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
                showAlert.accept(true)
                alertContents.accept(user.nickname)
            }
            .disposed(by: disposeBag)
        
        input.cancelBtnTapped
            .bind { _ in
                showAlert.accept(false)
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
                    showAlert.accept(!value)
                    owner.coordinator.dismissVC()
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.backBtnTapped
            .bind(with: self) { owner, _ in
                owner.coordinator.dismissVC()
            }
            .disposed(by: disposeBag)
        
        return Output(
            channelMembers: channelMembers.asDriver(onErrorJustReturn: []),
            showAlert: showAlert.asDriver(onErrorJustReturn: false),
            alertContents: alertContents.asDriver(onErrorJustReturn: "")
        )
    }
}
