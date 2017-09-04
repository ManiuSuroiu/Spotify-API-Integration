//
//  LandscapeViewController.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 01/09/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var pageControl: UIPageControl!
  
  var searchResults = [SearchResult]()
  private var firstTime = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.removeConstraints(view.constraints) /* remove the constraints generated automatically by Xcode */
    view.translatesAutoresizingMaskIntoConstraints = true /* allows us to position and size our views manually by changing their frame property */
    
    pageControl.removeConstraints(pageControl.constraints)
    pageControl.translatesAutoresizingMaskIntoConstraints = true
    pageControl.numberOfPages = 0
    
    scrollView.removeConstraints(scrollView.constraints)
    scrollView.translatesAutoresizingMaskIntoConstraints = true
    scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    scrollView.frame = view.bounds
    
    pageControl.frame = CGRect(x: 0,
                               y: view.frame.size.height - pageControl.frame.size.height,
                               width: view.frame.size.width,
                               height: pageControl.frame.size.height)
    
    if firstTime {
      firstTime = false
      tileButtons(searchResults)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
  }
  
  deinit {
    print("deinit \(self)")
  }
  
  private func tileButtons(_ searchResults: [SearchResult]) {
    
    var columnsPerPage = 6
    var rowsPerPage = 3
    var itemWidth: CGFloat = 94
    var itemHeight: CGFloat = 88
    var marginX: CGFloat = 2
    var marginY: CGFloat = 20
    
    let scrollViewWidth = scrollView.bounds.size.width
    
    switch scrollViewWidth {
    case 667:
      columnsPerPage = 7
      itemWidth = 95
      itemHeight = 98
      marginX = 1
      marginY = 29
    case 736:
      columnsPerPage = 8
      rowsPerPage = 4
      itemWidth = 92
    default:
      break
    }
    
    let buttonWidth: CGFloat = 82
    let buttonHeight: CGFloat = 82
    let paddingHorz = (itemWidth - buttonWidth)/2
    let paddingVert = (itemHeight - buttonHeight)/2
    
    var row = 0
    var column = 0
    var x = marginX
    
    for (index, searchResult) in searchResults.enumerated() {
      let button = UIButton(type: .system)
      button.backgroundColor = UIColor.white
      button.setTitle("\(index)", for: .normal)
      
      button.frame = CGRect(x: x + paddingHorz,
                            y: marginY + CGFloat(row) * itemHeight + paddingVert,
                            width: buttonWidth,
                            height: buttonHeight)
      scrollView.addSubview(button)
      
      row += 1
      if row == rowsPerPage {
        row = 0; x += itemWidth; column += 1
        
        if column == columnsPerPage {
          column = 0; x += marginX * 2
        }
      }
    }
    
    let buttonsPerPage = columnsPerPage * rowsPerPage
    let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
    
    scrollView.contentSize = CGSize(width: CGFloat(numPages) * scrollViewWidth,
                                    height: scrollView.bounds.size.height)
    print("Number of pages: \(numPages)")
    
    pageControl.numberOfPages = numPages
    pageControl.currentPage = 0
  }
  
  @IBAction func pageChanged(_ sender: UIPageControl) {
    UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
      self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage),
                                              y: 0)
    }, completion: nil)
    
  }
}

extension LandscapeViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let width = scrollView.bounds.size.width
    let currentPage = Int((scrollView.contentOffset.x + width/2)/width)
    pageControl.currentPage = currentPage
  }
}










