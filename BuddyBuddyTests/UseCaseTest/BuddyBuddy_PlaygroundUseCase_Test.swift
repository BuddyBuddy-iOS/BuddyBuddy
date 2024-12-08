//
//  BuddyBuddy_PlaygroundUseCase_Test.swift
//  BuddyBuddyTests
//
//  Created by Jisoo Ham on 12/9/24.
//

import XCTest

@testable
import BuddyBuddy

import RxCocoa
import RxSwift

final class BuddyBuddy_PlaygroundUseCase_Test: XCTestCase {
    private var repository: PlaygroundRepositoryInterface!
    private var useCase: PlaygroundUseCaseInterface!
    private var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        repository = MockPlaygroundRepository()
        DIContainer.register(
            type: PlaygroundRepositoryInterface.self,
            MockPlaygroundRepository()
        )
        useCase = DefaultPlaygroundUseCase()
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        repository = nil
        useCase = nil
        disposeBag = nil
    }

    func test_FetchPlaygroundInfo_Success() throws {
        let expectation = expectation(description: "playground info Test")
        var expectedResults: [SearchResult] = []
        fetchData(playground: .playgroundInfo) { value in
            expectedResults = value
            expectation.fulfill()
        }
        
        let _ = useCase.fetchPlaygroundInfo()
            .subscribe { result in
                switch result {
                case .success(let value):
                    XCTAssertEqual(value, expectedResults)
                case .failure(let error):
                    XCTFail("Unexpected failure: \(error)")
                }
            } onFailure: { error in
                XCTFail("Unexpected failure: \(error)")
                expectation.fulfill()
            }
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 3)
    }
    
    func test_SearchPlayground_Success() throws {
        let expectation = expectation(description: "Search in Playground Test")
        var expectedResults: [SearchResult] = []
        fetchData(playground: .search) { value in
            expectedResults = value
            expectation.fulfill()
        }
        
        let _ = useCase.searchInPlayground(text: "")
            .subscribe { result in
                switch result {
                case .success(let value):
                    XCTAssertEqual(value, expectedResults)
                case .failure(let error):
                    XCTFail("Unexpected failure: \(error)")
                }
            } onFailure: { error in
                XCTFail("Unexpected failure: \(error)")
                expectation.fulfill()
            }
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 3)
    }
    
    func fetchData(playground: Playground, completion: @escaping (([SearchResult]) -> Void)) {
        guard let path = Bundle.main.path(
            forResource: playground.toFileName,
            ofType: "json"
        ) else {
            return
        }
        
        guard let jsonString = try? String(contentsOfFile: path) else {
            return
        }
        
        let decoder = JSONDecoder()
        let data = jsonString.data(using: .utf8)
        if let data = data {
            do {
                let result = try decoder.decode(
                    SearchDTO.self,
                    from: data
                )
                completion(result.toDomain())
            } catch {
                return
            }
        } else {
            return
        }
    }
}
