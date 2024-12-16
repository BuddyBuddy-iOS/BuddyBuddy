//
//  DefaultHomeCoordinator.swift
//  BuddyBuddy
//
//  Created by Jisoo Ham on 11/6/24.
//

import UIKit

final class DefaultHomeCoordinator: HomeCoordinator {
    @Dependency(ChannelUseCaseInterface.self)
    private var channelUseCase: ChannelUseCaseInterface
    @Dependency(PlaygroundUseCaseInterface.self)
    private var playgroundUseCase: PlaygroundUseCaseInterface
    var parent: Coordinator?
    var childs: [Coordinator] = []
    var navigationController: UINavigationController
    
    private lazy var homeVM = HomeViewModel(
        coordinator: self,
        channelUseCase: channelUseCase, 
        playgroundUseCase: playgroundUseCase
    )
    private let slideType: SlideType = .trailing
    private var channelSettingVM: ChannelSettingViewModel?
    private var presentation: SlidePresentationController?
    private var manager: SlideInPresentationManager?
    private var naviForChannelAmdin = UINavigationController()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = HomeViewController(vm: homeVM)
        navigationController.pushViewController(
            vc,
            animated: true
        )
    }
    
    func toChannelSetting(channelID: String) {
        channelSettingVM = ChannelSettingViewModel(
            coordinator: self,
            useCase: channelUseCase,
            channelID: channelID
        )
        
        guard let channelSettingVM else { return }
        let vc = ChannelSettingViewController(vm: channelSettingVM)
        
        presentation = SlidePresentationController(
            presentedViewController: vc,
            presenting: nil,
            type: slideType
        )
        presentation?.sideMenuDelegate = vc
        
        guard let presentation else { return }
        
        manager = SlideInPresentationManager(
            presentationController: presentation,
            type: slideType
        )
        
        vc.hidesBottomBarWhenPushed = true
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = manager
        
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        navigationController.present(
            vc,
            animated: true
        )
    }
    
    func toChannelAdmin(channelID: String) {
        let vc = ChannelAdminViewController(vm: ChangeAdminViewModel(
            coordinator: self,
            useCase: DefaultChannelUseCase(),
            channelID: channelID
        ))
        naviForChannelAmdin.navigationBar.isHidden = true
        naviForChannelAmdin.setViewControllers(
            [vc],
            animated: true
        )
        naviForChannelAmdin.modalPresentationStyle = .pageSheet
        if let sheet = naviForChannelAmdin.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        if let presentedVC = navigationController.presentedViewController {
            presentedVC.present(
                naviForChannelAmdin,
                animated: true
            )
        }
    }
    
    func toInviteMember() {
        let vc = InviteMemberViewController(vm: InviteMemberViewModel(coordinator: self))
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        navigationController.present(
            vc,
            animated: true
        )
    }
    
    func toProfile(userID: String) {
        let vc = ProfileViewController(vm: ProfileViewModel(
            coordinator: self,
            userUseCase: DefaultUserUseCase(),
            userID: userID
        ))
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        navigationController.present(
            vc,
            animated: true
        )
    }
   
    func toChannelDM(channelID: String) {
        let vc = ChannelChattingViewController(vm: ChannelChattingViewModel(
            coordinator: self,
            channelUseCase: DefaultChannelUseCase(),
            channelID: channelID
        ))
        vc.hidesBottomBarWhenPushed = true
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        navigationController.pushViewController(
            vc,
            animated: true
        )
    }
    
    func toAddChannel() {
        let vm = AddChannelViewModel(
            channelUseCase: channelUseCase,
            coordinator: self
        )
        vm.delegate = homeVM
        
        let vc = AddChannelViewController(vm: vm)
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        navigationController.present(
            vc,
            animated: true
        )
    }
    
    func toPlayground() {
        let coordinator = DefaultPlaygroundCoordinator(
            navigationController: navigationController, 
            playgroundUseCase: playgroundUseCase
        )
        coordinator.parent = self
        coordinator.delegate = homeVM
        childs.append(coordinator)
        coordinator.start()
    }
    
    func dismissModal() {
        if let presentedVC = navigationController.presentedViewController {
            presentedVC.dismiss(animated: true)
        }
    }
}
