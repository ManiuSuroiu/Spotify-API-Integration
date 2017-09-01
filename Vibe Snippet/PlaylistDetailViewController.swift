//
//  PlaylistDetailViewController.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 13/08/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

class PlaylistDetailViewController: UIViewController {
  
  @IBOutlet weak var popupView: UIView!
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var playlistNameLabel: UILabel!
  @IBOutlet weak var tracksNumberLabel: UILabel!
  @IBOutlet weak var playlistOwnerNameLabel: UILabel!
  @IBOutlet weak var takeMeToSpotify: UIButton!
  
  enum AnimationStyle {
    case fade
    case slide
  }
  
  var dismissedAnimationStyle = AnimationStyle.fade
  var searchResult: SearchResult!
  var downloadTask: URLSessionDownloadTask?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.tintColor = UIColor(red: 10/255, green: 150/255, blue: 255/255, alpha: 1)
    view.backgroundColor = UIColor.clear
    
    popupView.layer.cornerRadius = 10
    
    /* Customize UIButton */
    takeMeToSpotify.layer.cornerRadius = 20
    takeMeToSpotify.layer.masksToBounds = true
    takeMeToSpotify.backgroundColor = UIColor(red: 10/255, green: 150/255, blue: 255/255, alpha: 0.3)
    takeMeToSpotify.setBackgroundColor(color: .init(red: 10/255, green: 150/255, blue: 255/255, alpha: 1),
                                       for: .highlighted)
    
    /* Gesture recognizer that listens to taps inside the view controller and calls the close() method in response */
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
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    modalPresentationStyle = .custom
    transitioningDelegate = self
  }
  
  @IBAction func close() {
    dismissedAnimationStyle = .slide
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func openSpotify() {
    if let url = URL(string: searchResult.spotifyURLForPlaylist) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
  
  func updateUI() {
    playlistNameLabel.text = searchResult.playlistName
    tracksNumberLabel.text = "\(searchResult.numberOfTracks)"
    
    if searchResult.playlistOwner.isEmpty {
      playlistOwnerNameLabel.text = "Unknown"
    } else {
      playlistOwnerNameLabel.text = searchResult.playlistOwner
    }
    
    if let imageURL = URL(string: searchResult.largeImageURL) {
      downloadTask = artworkImageView.loadImage(url: imageURL)
    }
  }
}

// MARK: UIViewControllerTransitioningDelegate

extension PlaylistDetailViewController: UIViewControllerTransitioningDelegate {
  
  func presentationController(forPresented presented: UIViewController,
                              presenting: UIViewController?,
                              source: UIViewController) -> UIPresentationController? {
    return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
  }
  
  /* Present the transition animator object */
  func animationController(forPresented presented: UIViewController,
                           presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return BounceAnimationController()
  }
  
  /* Present the transition animator object when dismissing the vc */
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
    switch dismissedAnimationStyle {
    case .fade:
      return FadeOutAnimationController()
    case .slide:
      return SlideOutAnimationController()
    }
  }
}

// MARK: UIGestureRecognizerDelegate

extension PlaylistDetailViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                         shouldReceive touch: UITouch) -> Bool {
    return (touch.view === self.view)
  }
}










