//
//  DetailViewController.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 11/08/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

class TrackDetailViewController: UIViewController {
  
  // MARK: Outlets
  @IBOutlet weak var popupView: UIView!
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var trackNameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var popularityValueLabel: UILabel!
  @IBOutlet weak var downloadButton: UIButton!
  @IBOutlet weak var playButton: UIButton!
  @IBOutlet weak var pauseDownloadButton: UIButton!
  @IBOutlet weak var cancelDownloadButton: UIButton!
  @IBOutlet weak var downloadProgressView: UIProgressView!
  @IBOutlet weak var downloadProgressLabel: UILabel!
  
  var searchResult: SearchResult!
  private var downloadTask: URLSessionDownloadTask?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.tintColor = UIColor(red: 10/255, green: 150/255, blue: 255/255, alpha: 1)
    
    /* Makes the corners of the view rounded */
    popupView.layer.cornerRadius = 10
    
    /* Make the gesture recognizer that listens to taps inside the view controller and calls the close() method in response */
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
    gestureRecognizer.cancelsTouchesInView = false
    gestureRecognizer.delegate = self
    view.addGestureRecognizer(gestureRecognizer)
    
    if let _ = searchResult {
      updateUI()
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  deinit {
    print("Deinit \(self)")
    downloadTask?.cancel()
  }
  
  @IBAction func close() {
    dismiss(animated: true, completion: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    modalPresentationStyle = .custom
    transitioningDelegate = self
  }
  
  func updateUI() {
    trackNameLabel.text = searchResult.trackName
    artistNameLabel.text = searchResult.artistName
    popularityValueLabel.text = "\(searchResult.trackPopularity)"
    
    if let imageURL = URL(string: searchResult.largeImageURL) {
      downloadTask = artworkImageView.loadImage(url: imageURL)
    }
  }
}

// MARK: UIViewControllerTransitioningDelegate - Tells UIKit that we are using a custom presentation controller to present the detail pop-up

extension TrackDetailViewController: UIViewControllerTransitioningDelegate {
  
  /* The transition from SearchViewController to DetailViewController will be performed by the DimmingViewController rather than a standard presentation controller */
  func presentationController(forPresented presented: UIViewController,
                              presenting: UIViewController?,
                              source: UIViewController) -> UIPresentationController? {
    return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
  }
}

// MARK: UIGestureRecognizerDelegate - Allow users to dismiss the pop-up by tapping anywhere outside it

extension TrackDetailViewController: UIGestureRecognizerDelegate {
  
  /* Returns true when the touch was on the background view and false when it was inside the Pop-up view */
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                         shouldReceive touch: UITouch) -> Bool {
    return (touch.view === self.view)
  }
}








