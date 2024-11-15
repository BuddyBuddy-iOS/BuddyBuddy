//
//  DMUseCase.swift
//  BuddyBuddy
//
//  Created by 김성률 on 11/12/24.
//

import Foundation

import RxSwift

protocol DMUseCase {
    func fetchDMList(plagroundID: String) -> Single<Result<[DMList], Error>>
}
