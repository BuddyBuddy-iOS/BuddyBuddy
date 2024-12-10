//
//  SlidePresentationController.swift
//  BuddyBuddy
//
//  Created by 아라 on 12/5/24.
//

import UIKit

import SnapKit

final class SlidePresentationController: UIPresentationController {
    let dimmingView = UIView()
    private let type: SlideType
    weak var sideMenuDelegate: SideMenuHandler?
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard var frame = containerView?.frame else {
            return .zero
        }
        
        let originWidth = frame.width
        
        frame.size.width *= 0.8
        frame.size.height = frame.size.height
        
        frame.origin = CGPoint(
            x: type == .leading ? 0 : originWidth - frame.size.width,
            y: 0
        )
        
        return frame
    }
    
    var transitionCoordinator: UIViewControllerTransitionCoordinator?
    
    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        type: SlideType
    ) {
        self.type = type
        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func presentationTransitionWillBegin() {
        setupDimmingViewLayout()
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.5
            return
        }
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self else { return }
            dimmingView.alpha = 0.5
        })
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(
                alongsideTransition: { [weak self] _ in
                    guard let self else { return }
                    dimmingView.alpha = 0.0
                    presentingViewController.view.transform = CGAffineTransform.identity
                    containerView?.layoutIfNeeded()
                }, 
                completion: nil
            )
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        presentingViewController.endAppearanceTransition()
        if completed {
            dimmingView.removeFromSuperview()
        }
    }
}

extension SlidePresentationController {
    func setupDimmingViewLayout() {
        dimmingView.alpha = 0.0
        dimmingView.backgroundColor = .black
        
        containerView?.insertSubview(dimmingView, at: 0)
        
        dimmingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap)
        )
        dimmingView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {
        sideMenuDelegate?.dismissNotification()
    }
}
