//
//  SlideTransition.swift
//  BuddyBuddy
//
//  Created by 아라 on 12/9/24.
//

import UIKit

final class SlideTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var isPresenting = false
    private let type: SlideType
    
    init(isPresenting: Bool = false, type: SlideType) {
        self.isPresenting = isPresenting
        self.type = type
    }
    
    func transitionDuration(using transitionContext:
                            (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let fromViewController = transitionContext.viewController(forKey: .from)
        else { return }
        
        let containerView = transitionContext.containerView
        let fullWidth = containerView.bounds.width
        
        let width = toViewController.view.bounds.width
        let height = toViewController.view.bounds.height
        var initialX: CGFloat = 0.0
        
        switch type {
        case .leading:
            initialX = -width
        case .trailing:
            initialX = width
        }
        
        if isPresenting {
            containerView.addSubview(toViewController.view)
            toViewController.view.frame = CGRect(
                x: initialX,
                y: 0,
                width: width,
                height: height
            )
        }
        
        let duration = transitionDuration(using: transitionContext)
        let isCancelled = transitionContext.transitionWasCancelled
        
        UIView.animate(
            withDuration: duration,
            animations: { [weak self] in
                guard let self else { return }
                
                var translationX: CGFloat =  0.0
                
                switch type {
                case .leading:
                    translationX = width
                case .trailing:
                    translationX = -width
                }
                
                if isPresenting {
                    toViewController.view.transform = CGAffineTransform(
                        translationX: translationX,
                        y: 0
                    )
                } else {
                    fromViewController.view.transform = .identity
                }
            }) { _ in
                transitionContext.completeTransition(!isCancelled)
            }
    }
}
