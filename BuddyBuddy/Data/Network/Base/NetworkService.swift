//
//  NetworkManager.swift
//  BuddyBuddy
//
//  Created by 김성률 on 11/12/24.
//

import Foundation

import Alamofire
import RxSwift

final class NetworkService: NetworkProtocol {
    
    private var isConnectedNetwork: Bool = false
    
    static let session: Session = {
        let configuration = URLSessionConfiguration.af.default
        let logger = NetworkLogger()
        return Session(
            configuration: configuration,
            eventMonitors: [logger]
        )
    }()
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNetworkChange),
            name: .networkConnected,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNetworkChange),
            name: .networkDisconnected,
            object: nil
        )
    }
    
    func callRequest<T: Decodable>(
        router: TargetType,
        responseType: T.Type
    ) -> Single<Result<T, Error>> {
        if isConnectedNetwork {
            return Single.create { observer -> Disposable in
                do {
                    let request = try router.asURLRequest()
                    NetworkService.session.request(
                        request,
                        interceptor: AuthIntercepter()
                    )
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: responseType.self) { response in
                        switch response.result {
                        case .success(let value):
                            observer(.success(.success(value)))
                        case .failure(let error):
                            observer(.success(.failure(error)))
                        }
                    }
                } catch {
                    print(error)
                }
                return Disposables.create()
            }
        } else {
            return Single.create { observer -> Disposable in
                return Disposables.create()
            }
        }
    }
    
    func downloadImage(router: TargetType) -> Single<Result<Data?, Error>> {
        if isConnectedNetwork {
            return Single.create { observer -> Disposable in
                do {
                    let request = try router.asURLRequest()
                    NetworkService.session.download(request)
                        .validate(statusCode: 200..<300)
                        .responseData { response in
                            switch response.result {
                            case .success(let value):
                                observer(.success(.success(value)))
                            case .failure(_):
                                observer(.success(.success(nil)))
                            }
                        }
                } catch {
                    print(error)
                }
                
                return Disposables.create()
            }
        } else {
            return Single.create { observer -> Disposable in
                return Disposables.create()
            }
        }
    }
    
    func callRequest(router: TargetType) -> Single<Result<Void, Error>> {
        return Single.create { observer -> Disposable in
            do {
                let request = try router.asURLRequest()
                NetworkService.session.request(
                    request,
                    interceptor: AuthIntercepter()
                )
                .validate(statusCode: 200..<300)
                .response { response in
                    switch response.result {
                    case .success:
                        observer(.success(.success(())))
                    case .failure(let error):
                        observer(.success(.failure(error)))
                    }
                }
            } catch {
                print(error)
            }
            return Disposables.create()
        }
    }
    
    @objc private func handleNetworkChange(_ notification: Notification) {
        switch notification.name {
        case Notification.Name.networkConnected:
            networkResult(notiName: Notification.Name.networkConnected)
        case Notification.Name.networkDisconnected:
            networkResult(notiName: Notification.Name.networkDisconnected)
        default:
            break
        }
    }
    
    private func networkResult(notiName: Notification.Name) {
        if notiName == Notification.Name.networkConnected {
            isConnectedNetwork = true
        } else {
            isConnectedNetwork = false
        }
    }
}

extension NetworkService {
    func callMultiPart<T: Decodable>(
        router: TargetType,
        responseType: T.Type,
        content: String,
        files: [Data]
    ) -> Single<Result<T, Error>> {
        if isConnectedNetwork {
            return Single.create { observer -> Disposable in
                do {
                    let request = try router.asURLRequest()
                    NetworkService.session.upload(
                        multipartFormData: { multipartFormData in
                            if let contentData = content.data(using: .utf8) {
                                multipartFormData.append(
                                    contentData,
                                    withName: "content"
                                )
                            } else {
                                print("content를 Data로 변환할 수 없습니다.")
                            }
                            
                            for (index, data) in files.enumerated() {
                                multipartFormData.append(
                                    data,
                                    withName: "files",
                                    fileName: "file\(index + 1).jpg",
                                    mimeType: "image/jpeg"
                                )
                            }
                        },
                        with: request,
                        interceptor: AuthIntercepter()
                    )
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: T.self) { response in
                        switch response.result {
                        case .success(let value):
                            observer(.success(.success(value)))
                        case .failure(let error):
                            observer(.success(.failure(error)))
                        }
                    }
                } catch {
                    print(error)
                }
                return Disposables.create()
            }
        } else {
            return Single.create { observer -> Disposable in
                return Disposables.create()
            }
        }
    }
}
