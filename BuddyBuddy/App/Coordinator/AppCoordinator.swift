//
//  AppCoordinator.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/6/24.
//

import UIKit

final class AppCoordinator: Coordinator {
    var parent: Coordinator?
    var childs: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotification),
            name: Notification.Name("Login"),
            object: nil
        )
        KeyChainManager.shared.deleteAccessToken()
        KeyChainManager.shared.deleteRefreshToken()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name("Login"),
            object: nil
        )
    }
    
    func start() {
        // MARK: 현재 특정 워크스페이스 고정이기 때문에 워크스페이스에 포함되어있는 형태가 아니라면 Retry가 뜰 예정
        // +) 애플 로그인 -> 스웨거로 TED 가입 -> 키체인 삭제 -> 로그인 시 테스트 가능
        
        checkPlayground()
        
        if KeyChainManager.shared.getAccessToken() != nil {
            startTab()
        } else {
            startLogin()
        }
    }
    
    private func startTab() {
        let tabCoordinator = TabBarCoordinator(navigationController: navigationController)
        tabCoordinator.parent = self
        childs.append(tabCoordinator)
        tabCoordinator.start()
    }
    
    private func startLogin() {
        let loginCoordinator = DefaultAuthCoordinator(navigationController: navigationController)
        loginCoordinator.parent = self
        childs.append(loginCoordinator)
        loginCoordinator.start()
    }
    
    @objc private func handleNotification() {
        KeyChainManager.shared.deleteAccessToken()
        KeyChainManager.shared.deleteRefreshToken()
        
        finish()
        startLogin()
    }
    
    private func checkPlayground() {
        if UserDefaultsManager.playgroundID == UserDefaultsManager.Key.playgroundID.rawValue {
            UserDefaultsManager.playgroundID = "70b565b8-9ca1-483f-b812-15d3e57b5cf4"
        }
    }
}
