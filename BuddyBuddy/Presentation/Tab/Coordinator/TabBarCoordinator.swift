//
//  TabBarCoordinator.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/6/24.
//

import UIKit

final class TabBarCoordinator: Coordinator {
    var parent: Coordinator?
    var childs: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        setupTabBarController()
    }
}

extension TabBarCoordinator {
    private func setupTabBarController() {
        let tabBarController = TabBarViewController()
        let viewControllers = TabKind.allCases.map { tabKind in
            makeNavigationController(for: tabKind)
        }
        tabBarController.viewControllers = viewControllers
        tabBarController.tabBar.tintColor = .black
        navigationController.setViewControllers(
            [tabBarController],
            animated: true
        )
    }
    
    private func makeNavigationController(for tabKind: TabKind) -> UINavigationController {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = UITabBarItem(
            title: tabKind.tabTitle,
            image: UIImage(named: "\(tabKind.unselectedImg)"),
            selectedImage: UIImage(named: "\(tabKind.selectedImg)")
        )
        navigationController.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.black
        ]
        
        setupChildCoordinator(
            for: tabKind,
            navigationController: navigationController
        )
        
        return navigationController
    }
    
    private func setupChildCoordinator(
        for tabKind: TabKind,
        navigationController: UINavigationController
    ) {
        let coordinator: Coordinator
        
        switch tabKind {
        case .home:
            coordinator = DefaultHomeCoordinator(navigationController: navigationController)
        case .dm:
            coordinator = DefaultDMCoordinator(navigationController: navigationController)
        case .search:
            coordinator = DefaultSearchCoordinator(navigationController: navigationController)
        case .setting:
            coordinator = DefaultSettingCoordinator(navigationController: navigationController)
        }
        
        coordinator.parent = self
        childs.append(coordinator)
        coordinator.start()
    }
}
