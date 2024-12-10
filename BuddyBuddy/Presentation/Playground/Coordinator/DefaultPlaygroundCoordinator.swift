//
//  DefaultPlaygroundCoordinator.swift
//  BuddyBuddy
//
//  Created by 아라 on 12/3/24.
//

import UIKit

final class DefaultPlaygroundCoordinator: PlaygroundCoordinator {
    var parent: Coordinator?
    var childs: [Coordinator] = []
    var navigationController: UINavigationController
    
    weak var delegate: ModalDelegate?
    @Dependency(PlaygroundUseCaseInterface.self)
    private var playgroundUseCase: PlaygroundUseCaseInterface
    private lazy var vc = PlaygroundViewController(vm: vm)
    private lazy var vm = PlaygroundViewModel(
        coordinator: self,
        useCase: playgroundUseCase
    )
    private let slideType: SlideType = .leading
    private lazy var presentation = {
        let controller = SlidePresentationController(
            presentedViewController: vc,
            presenting: nil,
            type: slideType
        )
        controller.sideMenuDelegate = vc
        return controller
    }()
    private lazy var manager = SlideInPresentationManager(
        presentationController: presentation,
        type: slideType
    )
    
    init(
        navigationController: UINavigationController,
        playgroundUseCase: PlaygroundUseCaseInterface
    ) {
        self.navigationController = navigationController
    }
    
    func start() {
        vm.delegate = delegate
        
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = manager
        
        navigationController.present(
            vc,
            animated: true
        )
    }
    
    func presentActionSheet() {
        var actionSheet: UIAlertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        setActionSheet(&actionSheet)
        
        vc.present(
            actionSheet,
            animated: true
        )
    }
}

extension DefaultPlaygroundCoordinator {
    func setActionSheet(_ actionSheet: inout UIAlertController) {
        for type in ActionSheetType.allCases {
            let action = UIAlertAction(
                title: type.title,
                style: (type == .cancel) ? .cancel : (type == .delete) ? .destructive : .default
            ) { [weak self] _ in
                guard let self else { return }
                vm.actionSheetTrigger(type)
            }
            
            actionSheet.addAction(action)
        }
    }
}
