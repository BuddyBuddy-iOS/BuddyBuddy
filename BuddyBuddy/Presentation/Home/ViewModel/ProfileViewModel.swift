//
//  ProfileViewModel.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/14/24.
//

import Foundation

import RxCocoa
import RxSwift

final class ProfileViewModel: ViewModelType {
    private let disposeBag: DisposeBag = DisposeBag()
    private let coordinator: Coordinator
    private let userUseCase: UserUseCaseInterface
    
    private let userID: String
    
    private let dummyUser: UserProfile = UserProfile(
        userID: "0edf1891-c605-4fbb-82cb-e50bca521137",
        email: "compose1@coffee.com",
        nickname: "씩씩이",
        profileImage: ""
    )
    
    weak var delegate: NavigateTabDelegate?
    
    init(
        coordinator: Coordinator,
        userUseCase: UserUseCaseInterface,
        userID: String
    ) {
        self.coordinator = coordinator
        self.userUseCase = userUseCase
        self.userID = userID
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let dmBtnTapped: Observable<Void>
    }
    
    struct Output {
        let userProfile: Driver<UserProfile>
    }
    
    func transform(input: Input) -> Output {
        let userProfile = PublishSubject<UserProfile>()
        var selectedUser = UserProfile(userID: "", email: "", nickname: "", profileImage: "")
        
        input.viewWillAppear
            .withUnretained(self)
            .flatMap { arg1 in
                return arg1.0.userUseCase.checkUserProfile(userID: arg1.0.userID)
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let user):
                    selectedUser = user
                    userProfile.onNext(user)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.dmBtnTapped
            .bind(with: self) { owner, _ in
                owner.delegate?.tappedDMButton(with: selectedUser.userID)
            }
            .disposed(by: disposeBag)
        
        return Output(userProfile: userProfile.asDriver(onErrorJustReturn: dummyUser))
    }
}
