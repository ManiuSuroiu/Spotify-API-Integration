//
//  SlideOutAnimationController.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 31/08/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

class SlideOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.3
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) {
      
      let containerView = transitionContext.containerView
      let duration = transitionDuration(using: transitionContext)
      
      UIView.animate(withDuration: duration,
                     animations: {
        fromView.center.y -= containerView.bounds.size.height
        fromView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
      },
                     completion: { finished in
        transitionContext.completeTransition(finished)
      })
    }
  }
}









