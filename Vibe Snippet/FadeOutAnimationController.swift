//
//  FadeOutAnimationController.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 01/09/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

class FadeOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.4
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) {
      
      let duration = transitionDuration(using: transitionContext)
      
      UIView.animate(withDuration: duration,
                     animations: {
        fromView.alpha = 0 },
                     completion: { finished in
        transitionContext.completeTransition(finished)
      })
    }
  }
}








