//
//  GradientView.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 30/08/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit
import CoreGraphics

class GradientView: UIView {
  
  /* Set the background color to transparent */
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.clear
    autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    backgroundColor = UIColor.clear
    autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }
  
  /* Draw the gradient on top of the transparent background */
  override func draw(_ rect: CGRect) {
  
    let components: [CGFloat] = [0, 0, 0, 0.3, 0, 0, 0, 0.7] /* It contains the 'color stops' for the gradient - both are black with 0.3 and 0.7 representing the opacity percentage */
    let locations: [CGFloat] = [0, 1] /* Represent percentages where we place the colors */
    
    /* Create the gradient using the two colors */
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let gradient = CGGradient(colorSpace: colorSpace,
                              colorComponents: components,
                              locations: locations,
                              count: 2)
    
    /* Figure out how big you need to draw it */
    let x = bounds.midX /* midX and midY return the center point of a rectangle (given by the bounds) */
    let y = bounds.midY
    let centerPoint = CGPoint(x: x, y: y) /* contains the coordinates for the center point of the view */
    let radius = max(x, y) /* contains the larger of the x and y values */
    
    /* Draw the gradient  - it takes place in a so-called graphics context */
    let context = UIGraphicsGetCurrentContext()
    context?.drawRadialGradient(gradient!,
                                startCenter: centerPoint,
                                startRadius: 0,
                                endCenter: centerPoint,
                                endRadius: radius,
                                options: .drawsAfterEndLocation)
  }
  
}













