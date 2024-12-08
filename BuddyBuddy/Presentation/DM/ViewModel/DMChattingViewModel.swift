//
//  DMChattingViewModel.swift
//  BuddyBuddy
//
//  Created by 김성률 on 11/12/24.
//

import UIKit

import RxCocoa
import RxSwift

final class DMChattingViewModel: ViewModelType {
    private let disposeBag = DisposeBag()
    
    private let coordinator: DMCoordinator
    private let dmUseCase: DMUseCaseInterface
    private let dmChatState: DMChatState
    private var roomID: String?
    private var userName: String?
    
    init(
        coordinator: DMCoordinator,
        dmUseCase: DMUseCaseInterface,
        dmChatState: DMChatState
    ) {
        self.coordinator = coordinator
        self.dmUseCase = dmUseCase
        self.dmChatState = dmChatState
    }
    
    deinit {
        print("dmchatviewmodel deinit")
    }
    
    struct Input {
        let viewWillAppearTrigger: Observable<Void>
        let sendBtnTapped: Observable<Void>
        let plusBtnTapped: Observable<Void>
        let chatBarText: Observable<String>
        let imagePicker: Observable<[UIImage]>
    }
    
    struct Output {
        let updateDMListTableView: Driver<[ChatSection<DMHistory>]>
        let scrollToDown: Driver<Void>
        let removeChattingBarTextAndImage: Driver<Void>
        let plusBtnTapped: Driver<Void>
        let imagePicker: Driver<[UIImage]>
        let dmListInfo: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let updateDMListTableView = PublishSubject<[ChatSection<DMHistory>]>()
        let scrollToDown = PublishSubject<Void>()
        let removeChattingBarText = PublishSubject<Void>()
        let dmListInfoSubject = BehaviorRelay<String>(value: userName ?? "")
        
        input.viewWillAppearTrigger
            .withUnretained(self)
            .flatMap { (owner, _) in
                switch owner.dmChatState {
                case .fromList(let dmListInfo):
                    owner.roomID = dmListInfo.roomID
                    owner.userName = dmListInfo.userName
                    return owner.dmUseCase.fetchDMHistory(
                        playgroundID: UserDefaultsManager.playgroundID,
                        roomID: dmListInfo.roomID
                    )
                case .fromProfile(let userID):
                    let dmListInfo = owner.dmUseCase.findRoomIDFromUser(userID: userID)
                    owner.roomID = dmListInfo.0
                    owner.userName = dmListInfo.1
                    return owner.dmUseCase.fetchDMHistory(
                        playgroundID: UserDefaultsManager.playgroundID,
                        roomID: dmListInfo.0
                    )
                }
            }
            .bind(with: self) { owner, response in
                switch response {
                case .success(let value):
                    let chatHistory = value.map { $0.toChatType() }
                    
                    updateDMListTableView.onNext([ChatSection(items: chatHistory)])
                    scrollToDown.onNext(())
                    dmListInfoSubject.accept(owner.userName ?? "")
                    
                    owner.dmUseCase.connectSocket(roomID: owner.roomID ?? "")
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        self.dmUseCase.observeMessage(roomID: roomID ?? "")
            .bind(with: self) { _, response in
                switch response {
                case .success(let value):
                    let chatHistory = value.map { $0.toChatType() }
                    updateDMListTableView.onNext([ChatSection(items: chatHistory)])
                    
                    scrollToDown.onNext(())
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.sendBtnTapped
            .withLatestFrom(Observable.combineLatest(
                input.chatBarText,
                input.imagePicker
            ))
            .withUnretained(self)
            .flatMap { owner, inputs -> Single<Result<[DMHistory], Error>> in
                let (text, images) = inputs
                return owner.dmUseCase.sendDM(
                    playgroundID: UserDefaultsManager.playgroundID,
                    roomID: owner.roomID ?? "",
                    message: text,
                    files: owner.imageToData(imageArray: images)
                )
            }
            .bind(with: self) { _, result in
                switch result {
                case .success(let value):
                    let chatHistory = value.map { $0.toChatType() }
                    updateDMListTableView.onNext([ChatSection(items: chatHistory)])

                    scrollToDown.onNext(())
                    removeChattingBarText.onNext(())
                    
//                    owner.dmUseCase.disConnectSocket()
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
            
        return Output(
            updateDMListTableView: updateDMListTableView.asDriver(onErrorJustReturn: []),
            scrollToDown: scrollToDown.asDriver(onErrorJustReturn: ()),
            removeChattingBarTextAndImage: removeChattingBarText.asDriver(onErrorJustReturn: ()),
            plusBtnTapped: input.plusBtnTapped.asDriver(onErrorJustReturn: ()),
            imagePicker: input.imagePicker.asDriver(onErrorJustReturn: []),
            dmListInfo: dmListInfoSubject.asDriver(onErrorDriveWith: .empty())
        )
    }
}

extension DMChattingViewModel {
    private func imageToData(imageArray: [UIImage]) -> [Data] {
        var dataArray: [Data] = []
        
        for item in imageArray {
            if let data = item.jpegData(compressionQuality: 0.5) {
                dataArray.append(data)
            } else {
                return []
            }
        }
        return dataArray
    }
}
