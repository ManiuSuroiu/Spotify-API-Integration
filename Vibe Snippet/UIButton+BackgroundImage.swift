//
//  UIButton+BackgroundImage.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 26/08/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

extension UIButton {
  
  // MARK: Manage colors for different states of the button
  func setBackgroundColor(color: UIColor, for state: UIControlState) {
    let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
    
    UIGraphicsBeginImageContext(rect.size)
    color.setFill()
    UIRectFill(rect)
    let colorImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    setBackgroundImage(colorImage, for: state)
  }
}










