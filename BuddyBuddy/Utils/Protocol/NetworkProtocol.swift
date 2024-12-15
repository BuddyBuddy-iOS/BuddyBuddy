//
//  NetworkProtocol.swift
//  BuddyBuddy
//
//  Created by 김성률 on 11/16/24.
//

import Foundation

import RxSwift

protocol NetworkProtocol {
    func callRequest<T: Decodable>(
        router: TargetType,
        responseType: T.Type
    ) -> Single<Result<T, Error>>
    
    func callMultiPart<T: Decodable>(
        router: TargetType,
        responseType: T.Type,
        content: String,
        files: [Data]
    ) -> Single<Result<T, Error>>

    func downloadImage(router: TargetType) -> Single<Result<Data?, Error>>
    func downloadImage(router: TargetType) async throws -> Data
    
    func callRequest(
        router: TargetType
    ) -> Single<Result<Void, Error>>
}
