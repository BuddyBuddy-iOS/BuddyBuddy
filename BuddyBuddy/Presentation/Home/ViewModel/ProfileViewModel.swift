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
    private let coordinator: HomeCoordinator
    
    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
    }
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        
        return Output()
    }
}
