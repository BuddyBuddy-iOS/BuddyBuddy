//
//  UserRepositoryInterface.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/21/24.
//

import Foundation

import RxCocoa
import RxSwift

protocol UserRepositoryInterface: AnyObject {
    func checkMyProfile() -> Single<Result<MyProfile, Error>>
    func checkUserProfile(userID: String) -> Single<Result<UserProfile, Error>>
    func loginWithApple(query: AppleLoginQuery) -> Single<Result<Bool, Error>>
    func loginWithEmail() -> Single<Result<Bool, Error>>
}
