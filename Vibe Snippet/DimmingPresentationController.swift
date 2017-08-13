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
}












