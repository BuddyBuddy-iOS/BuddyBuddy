//
//  ChannelChattingViewModel.swift
//  BuddyBuddy
//
//  Created by 김성률 on 12/3/24.
//

import UIKit

import RxCocoa
import RxSwift

final class ChannelChattingViewModel: ViewModelType {
    private let disposeBag = DisposeBag()
    
    private let coordinator: HomeCoordinator
    private let channelUseCase: ChannelUseCaseInterface
    private let channelID: String
    
    init(
        coordinator: HomeCoordinator,
        channelUseCase: ChannelUseCaseInterface,
        channelID: String
    ) {
        self.coordinator = coordinator
        self.channelUseCase = channelUseCase
        self.channelID = channelID
    }
    
    deinit {
        print("chatviewmodel deinit")
    }
    
    struct Input {
        let viewWillAppearTrigger: Observable<Void>
        let sendBtnTapped: Observable<Void>
        let plusBtnTapped: Observable<Void>
        let menuBtnTapped: Observable<Void>
        let chatBarText: Observable<String>
        let imagePicker: Observable<[UIImage]>
    }
    
    struct Output {
        let updateChannelChatTableView: Driver<[ChatSection<ChannelHistory>]>
        let scrollToDown: Driver<Void>
        let removeChattingBarTextAndImage: Driver<Void>
        let plusBtnTapped: Driver<Void>
        let imagePicker: Driver<[UIImage]>
    }
    
    func transform(input: Input) -> Output {
        let updateChannelChatTableView = PublishSubject<[ChatSection<ChannelHistory>]>()
        let scrollToDown = PublishSubject<Void>()
        let removeChattingBarText = PublishSubject<Void>()

        input.viewWillAppearTrigger
            .withUnretained(self)
            .flatMap { (owner, _) in
                owner.channelUseCase.fetchChannelHistory(
                    playgroundID: UserDefaultsManager.playgroundID,
                    channelID: owner.channelID
                )
            }
            .bind(with: self) { owner, response in
                switch response {
                case .success(let value):
                    let chatHistory = value.map { $0.toChatType() }
                    
                    updateChannelChatTableView.onNext([ChatSection(items: chatHistory)])
                    scrollToDown.onNext(())
                    
                    owner.channelUseCase.connectSocket(channelID: owner.channelID)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        self.channelUseCase.observeMessage(channelID: channelID)
            .bind(with: self) { _, response in
                switch response {
                case .success(let value):
                    let chatHistory = value.map { $0.toChatType() }
                    updateChannelChatTableView.onNext([ChatSection(items: chatHistory)])

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
            .flatMap { (owner, inputs) -> Single<Result<[ChannelHistory], Error>> in
                let (text, images) = inputs
                return owner.channelUseCase.sendChannel(
                    playgroundID: UserDefaultsManager.playgroundID,
                    channelID: owner.channelID,
                    message: text,
                    files: owner.imageToData(imageArray: images)
                )
            }
            .bind(with: self) { _, result in
                switch result {
                case .success(let value):
                    let chatHistory = value.map { $0.toChatType() }
                    updateChannelChatTableView.onNext([ChatSection(items: chatHistory)])

                    scrollToDown.onNext(())
                    removeChattingBarText.onNext(())
                    
//                    owner.dmUseCase.disConnectSocket()
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.menuBtnTapped
            .bind(with: self) { owner, _ in
                owner.coordinator.toChannelSetting(channelID: owner.channelID)
            }
            .disposed(by: disposeBag)
            
        return Output(
            updateChannelChatTableView: updateChannelChatTableView.asDriver(onErrorJustReturn: []),
            scrollToDown: scrollToDown.asDriver(onErrorJustReturn: ()),
            removeChattingBarTextAndImage: removeChattingBarText.asDriver(onErrorJustReturn: ()),
            plusBtnTapped: input.plusBtnTapped.asDriver(onErrorJustReturn: ()),
            imagePicker: input.imagePicker.asDriver(onErrorJustReturn: [])
        )
    }
}

extension ChannelChattingViewModel {
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
