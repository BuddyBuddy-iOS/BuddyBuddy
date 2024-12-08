//
//  MockPlaygroundRepository.swift
//  BuddyBuddyTests
//
//  Created by Jisoo Ham on 12/9/24.
//

import Foundation

@testable
import BuddyBuddy

import RxCocoa
import RxSwift

enum Playground {
    case search
    case playgroundInfo
    
    var toFileName: String {
        switch self {
        case .search:
            "BuddyWorkspaceSearch"
        case .playgroundInfo:
            "FetchWorkspaceInfo"
        }
    }
}

final class MockPlaygroundRepository: PlaygroundRepositoryInterface {
    
    func searchPlaygournd(text: String) -> Single<Result<[SearchResult], Error>> {
        let search = fetchData(playground: .search)
        
        return Single.just(.success(search))
    }
    func fetchPlaygroundInfo() -> Single<Result<[SearchResult], Error>> {
        let searchResults = fetchData(playground: .playgroundInfo)
        return Single.just(.success(searchResults))
    }
    
    func fetchData(playground: Playground) -> [SearchResult] {
        
        guard let path = Bundle.main.path(
            forResource: playground.toFileName,
            ofType: "json"
        ) else {
            return []
        }
        
        guard let jsonString = try? String(contentsOfFile: path) else {
            return []
        }
        let decoder = JSONDecoder()
        let data = jsonString.data(using: .utf8)
        if let data = data,
           let result = try? decoder.decode(
            SearchDTO.self,
            from: data
           ) {
            return result.toDomain()
        } else {
            return []
        }
    }
}
