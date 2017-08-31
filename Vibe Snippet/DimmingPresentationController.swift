//
//  DimmingPresentationController.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 12/08/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
  
  /* Once the detail pop-up is presented, the presenter's view (the SearchViewController) will still be visible by setting this property boolean value to false */ 
  override var shouldRemovePresentersView: Bool {
    return false
  }
  
  /* Create a new GradientView object */
  lazy var dimmingView = GradientView(frame: CGRect.zero)
  
  /* Invoked when the new view controller is about to be shown on the screen */
  override func presentationTransitionWillBegin() {
    /* Make the gradient view as big as the container view */
    dimmingView.frame = containerView!.bounds
    containerView!.insertSubview(dimmingView, at: 0)
  }
}












