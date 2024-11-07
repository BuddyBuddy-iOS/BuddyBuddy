//
//  DefaultSettingCoordinator.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/6/24.
//

import UIKit

final class DefaultSettingCoordinator: SettingCoordinator {
    var parent: Coordinator?
    var childs: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = SettingViewController(vm: SettingViewModel(coordinator: self))
        navigationController.pushViewController(
            vc,
            animated: true
        )
    }
}
