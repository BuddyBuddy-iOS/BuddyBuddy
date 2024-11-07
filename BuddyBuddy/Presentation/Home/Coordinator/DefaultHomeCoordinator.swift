//
//  DefaultHomeCoordinator.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/6/24.
//

import UIKit

final class DefaultHomeCoordinator: HomeCoordinator {
    var parent: Coordinator?
    var childs: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = HomeViewController(vm: HomeViewModel(coordinator: self))
        navigationController.pushViewController(
            vc,
            animated: true
        )
    }
}
