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
    }
    
    func start() {
        startTab()
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
}
