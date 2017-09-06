//
//  UIImage+Resize.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 05/09/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

extension UIImage {
  
  func resizedImage() -> UIImage {
    
    let newSize = CGSize(width: 60, height: 60)
    UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
    draw(in: CGRect(origin: CGPoint.zero, size: newSize))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
  }
}










