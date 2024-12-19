//
//  AuthIntercepter.swift
//  BuddyBuddy
//
//  Created by 김성률 on 11/13/24.
//

import Foundation

import Alamofire

final class AuthIntercepter: RequestInterceptor {
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var urlRequest = urlRequest
        urlRequest.setValue(
            KeyChainManager.shared.getAccessToken(),
            forHTTPHeaderField: Header.authorization.rawValue
        )
        completion(.success(urlRequest))
    }
    
    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard let response = request.task?.response as? HTTPURLResponse, 
                response.statusCode == 400 else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        do {
            let request = try AuthRouter.accessTokenRefresh.asURLRequest()
            session.request(request)
                .responseDecodable(of: AccessTokenDTO.self) { [weak self] response in
                    guard let self else { return }
                    switch response.result {
                    case .success(let value):
                        KeyChainManager.shared.saveAccessToken(value.accessToken)
                        completion(.retry)
                    case .failure:
                        guard let errorCode = self.decodeNetworkError(from: response.data) else {
                             return
                        }
                        let error = NetworkError(errorCode)
                        if error == NetworkError.E06 {
                            NotificationCenter.default.post(
                                name: NSNotification.Name("Login"),
                                object: nil
                            )
                        }
                        
                        completion(.doNotRetryWithError(error))
                    }
                }
        } catch {
            print(error)
        }
    }
    
    private func decodeNetworkError(from jsonData: Data?) -> String? {
        guard let jsonData else { return nil }
        
        if let errorResponse = try? JSONDecoder().decode(
            NetworkErrorDTO.self,
            from: jsonData
        ) {
            return errorResponse.errorCode
        }
        
        return nil
    }
}
