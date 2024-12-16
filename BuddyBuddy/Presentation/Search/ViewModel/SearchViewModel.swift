//
//  SearchViewModel.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/6/24.
//

import Foundation

import RxCocoa
import RxSwift

final class SearchViewModel: ViewModelType {
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let coordinator: SearchCoordinator
    private let playgroundUseCase: PlaygroundUseCaseInterface
    private let channelUseCase: ChannelUseCaseInterface
    
    weak var delegate: NavigateTabDelegate?
    
    init(
        coordinator: SearchCoordinator,
        playgroundUseCase: PlaygroundUseCaseInterface,
        channelUseCase: ChannelUseCaseInterface
    ) {
        self.coordinator = coordinator
        self.playgroundUseCase = playgroundUseCase
        self.channelUseCase = channelUseCase
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let inputText: Observable<String>
        let inputSegIndex: Observable<Int>
        let selectedCell: Observable<SearchResultType>
        let searchCancelBtnTapped: Observable<Void>
        let leftButtonTapped: Observable<Void>
        let rightButtonTapped: Observable<Void>
        let tappedAroundAlert: Observable<Void>
    }
    
    struct Output {
        let selectedSegIndex: Driver<Int>
        let searchData: Driver<SearchImageType>
        let searchedResult: Driver<[SearchResultType]>
        let emptyResult: Driver<Bool>
        let channelAlert: Driver<(Bool, String)>
    }
    
    func transform(input: Input) -> Output {
        let selectedSegIndex = PublishSubject<Int>()
        let searchData = PublishSubject<SearchImageType>()
        let searchedResult = PublishSubject<[SearchResultType]>()
        let emptyResult = PublishSubject<Bool>()
        let channelAlert = BehaviorSubject<(Bool, String)>(value: (true, ""))
        
        var searchResult: [SearchResult] = []
        var totalInfo: [SearchResult] = []
        var myChannels = MyChannelList()
        var channelID: String = ""
        
        input.viewWillAppear
            .withUnretained(self)
            .flatMap { (owner, _) in
                owner.playgroundUseCase.fetchPlaygroundInfo()
            }
            .bind(with: self) { owner, result in
                selectedSegIndex.onNext(0)
                switch result {
                case .success(let value):
                    searchResult = value
                    totalInfo = value
                    owner.updateSearchData(
                        state: .channel,
                        searchResult: searchResult,
                        searchedResult: searchedResult,
                        emptyResult: emptyResult
                    )
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.viewWillAppear
            .withUnretained(self)
            .flatMap { (owner, _) in
                owner.channelUseCase
                    .fetchMyChannelList(playgroundID: UserDefaultsManager.playgroundID)
            }
            .bind { result in
                switch result {
                case .success(let channels):
                    myChannels = channels
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.searchCancelBtnTapped
            .bind(with: self) { owner, _ in
                searchResult = totalInfo
                owner.updateSearchData(
                    state: .channel,
                    searchResult: searchResult,
                    searchedResult: searchedResult,
                    emptyResult: emptyResult
                )
                selectedSegIndex.onNext(0)
            }
            .disposed(by: disposeBag)
        
        input.inputText
            .withUnretained(self)
            .flatMap { (viewModel, inputText) in
                viewModel.playgroundUseCase.searchInPlayground(text: inputText)
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    searchResult = value
                    owner.updateSearchData(
                        state: .channel,
                        searchResult: searchResult,
                        searchedResult: searchedResult,
                        emptyResult: emptyResult
                    )
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.inputSegIndex
            .bind(with: self) { owner, segIndex in
                let state: SearchState = (segIndex == 0) ? .channel : .user
                owner.updateSearchData(
                    state: state,
                    searchResult: searchResult,
                    searchedResult: searchedResult,
                    emptyResult: emptyResult
                )
            }
            .disposed(by: disposeBag)
        
        input.selectedCell
            .bind(with: self) { owner, selected in
                switch selected {
                case .channel(let channel):
                    if myChannels.contains(where: { $0.channelID == channel.id }) {
                        owner.delegate?.tappedChannelChat(with: channel.id)
                    } else {
                        channelID = channel.id
                        channelAlert.onNext((false, channel.name))
                    }
                case .user(let user):
                    owner.coordinator.toProfile(userID: user.id)
                }
            }
            .disposed(by: disposeBag)
        
        input.leftButtonTapped
            .bind { _ in
                channelAlert.onNext((true, ""))
            }
            .disposed(by: disposeBag)
        
        input.rightButtonTapped
            .withUnretained(self)
            .flatMap { (owner, _) in
                owner.channelUseCase.fetchChannelChats(
                    channelID: channelID,
                    date: nil
                )
            }
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    channelAlert.onNext((value, ""))
                    owner.delegate?.tappedChannelChat(with: channelID)
                case .failure(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        input.tappedAroundAlert
            .bind { _ in
                channelAlert.onNext((true, ""))
            }
            .disposed(by: disposeBag)
        
        return Output(
            selectedSegIndex: selectedSegIndex.asDriver(onErrorJustReturn: 0),
            searchData: searchData.asDriver(onErrorJustReturn: .channel),
            searchedResult: searchedResult.asDriver(onErrorJustReturn: []),
            emptyResult: emptyResult.asDriver(onErrorJustReturn: false),
            channelAlert: channelAlert.asDriver(onErrorJustReturn: (false, ""))
        )
    }
    
    private func updateSearchData(
        state: SearchState,
        searchResult: [SearchResult],
        searchedResult: PublishSubject<[SearchResultType]>,
        emptyResult: PublishSubject<Bool>
    ) {
        let filteredResults = searchResult.filter { $0.state == state }
        let resultTypes: [SearchResultType] = filteredResults.map {
            state == .channel ? .channel($0) : .user($0)
        }
        
        searchedResult.onNext(resultTypes)
        emptyResult.onNext(resultTypes.isEmpty)
    }
}
