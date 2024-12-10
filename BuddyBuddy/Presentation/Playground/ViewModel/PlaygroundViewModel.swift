//
//  PlaygroundViewModel.swift
//  BuddyBuddy
//
//  Created by 아라 on 12/1/24.
//

import Foundation

import RxCocoa
import RxSwift

final class PlaygroundViewModel: ViewModelType {
    private let disposeBag = DisposeBag()
    private let coordinator: PlaygroundCoordinator
    private let useCase: PlaygroundUseCaseInterface
    private let showActionSheet = PublishRelay<Void>()
    private let actionSheetItemTapped = PublishRelay<ActionSheetType>()
    weak var delegate: ModalDelegate?
    
    init(
        coordinator: PlaygroundCoordinator,
        useCase: PlaygroundUseCaseInterface
    ) {
        self.coordinator = coordinator
        self.useCase = useCase
    }
    
    struct Input {
        let viewWillAppearTrigger: Observable<Void>
        let selectedPlayground: Observable<Workspace>
        let moreBtnTapped: Observable<String>
        let addBtnTapped: Observable<Void>
        let dismiss: Observable<Void>
    }
    
    struct Output {
        let playgroundList: Driver<PlaygroundList>
        let showExitAlert: Driver<Void>
        let showDeleteAlert: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let playgroundList = PublishRelay<PlaygroundList>()
        let showExitAlert = PublishRelay<Void>()
        let showDeleteAlert = PublishRelay<Void>()
        
        input.viewWillAppearTrigger
            .withUnretained(self)
            .flatMap { (owner, _) in
                owner.useCase.fetchPlaygroundList()
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    playgroundList.accept(value)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.selectedPlayground
            .bind(with: self) { owner, playground in
                UserDefaultsManager.playgroundID = playground.workspaceID
                owner.coordinator.dismissVC()
                owner.delegate?.dismissModal(message: nil)
            }
            .disposed(by: disposeBag)
        
        input.moreBtnTapped
            .bind(with: self) { owner, id in
                owner.coordinator.presentActionSheet()
            }
            .disposed(by: disposeBag)
        
        actionSheetItemTapped
            .bind(with: self) { owner, type in
                switch type {
                case .edit:
                    // TODO: 편집 화면 전환
                    break
                case .exit:
                    showExitAlert.accept(())
                case .changeAdmin:
                    // TODO: 관리자 변경 화면 전환
                    break
                case .delete:
                    showDeleteAlert.accept(())
                case .cancel:
                    break
                }
            }
            .disposed(by: disposeBag)
        
        input.addBtnTapped
            .bind(with: self) { owner, _ in
                // TODO: 생성 화면 전환
            }
            .disposed(by: disposeBag)
        
        input.dismiss
            .bind(with: self) { owner, _ in
                owner.coordinator.dismissVC()
            }
            .disposed(by: disposeBag)
        
        return Output(
            playgroundList: playgroundList.asDriver(onErrorJustReturn: []),
            showExitAlert: showExitAlert.asDriver(onErrorDriveWith: .empty()),
            showDeleteAlert: showDeleteAlert.asDriver(onErrorDriveWith: .empty())
        )
    }
}

extension PlaygroundViewModel {
    func actionSheetTrigger(_ type: ActionSheetType) {
        actionSheetItemTapped.accept(type)
    }
}
