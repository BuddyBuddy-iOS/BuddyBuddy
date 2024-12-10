//
//  SlidePresentationManager.swift
//  BuddyBuddy
//
//  Created by 아라 on 12/9/24.
//

import UIKit

final class SlideInPresentationManager: NSObject {
    var ratio: CGFloat
    var transition: SlideTransition?
    var presentationController: UIPresentationController
    let type: SlideType
    
    init(
        ratio: CGFloat = 0.8,
        transition: SlideTransition? = nil,
        presentationController: UIPresentationController,
        type: SlideType
    ) {
        self.ratio = ratio
        self.transition = SlideTransition(type: type)
        self.presentationController = presentationController
        self.type = type
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension SlideInPresentationManager: UIViewControllerTransitioningDelegate {
  func presentationController(
    forPresented presented: UIViewController,
    presenting: UIViewController?,
    source: UIViewController
  ) -> UIPresentationController? {
    return presentationController
  }

  func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
      transition?.isPresenting = true
      return transition
  }

  func animationController(
    forDismissed dismissed: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
      transition?.isPresenting = false
      return transition
  }
}
