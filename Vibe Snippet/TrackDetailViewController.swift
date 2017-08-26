//
//  DetailViewController.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 11/08/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class TrackDetailViewController: UIViewController {
  
  // MARK: Outlets
  @IBOutlet weak var popupView: UIView!
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var trackNameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var popularityValueLabel: UILabel!
  @IBOutlet weak var playButton: UIButton!
  
  /* Reference needed to populate the UI */
  var searchResult: SearchResult!
  
  /* Download task for downloading the image */
  private var downloadTask: URLSessionDownloadTask?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.tintColor = UIColor(red: 10/255, green: 150/255, blue: 255/255, alpha: 1)
    
    /* Makes the corners of the view rounded */
    popupView.layer.cornerRadius = 10
    
    // MARK: UIButton customization
    
    /* Make its corners rounded */
    playButton.layer.cornerRadius = 10
    
    /* Make the background image created for the highlighted state of the button take the same shape as the button (round corners) */
    playButton.layer.masksToBounds = true
    
    /* Set the background color in its default state */
    playButton.backgroundColor = UIColor(red: 10/255, green: 150/255, blue: 255/255, alpha: 0.3)
    
    /* Set the background color in its highlighted state using the UIButton extension */
    playButton.setBackgroundColor(color: .init(red: 10/255, green: 150/255, blue: 255/255, alpha: 1),
                                  for: .highlighted)
    
    /* Gesture recognizer that listens to taps inside the view controller and calls the close() method in response */
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
    gestureRecognizer.cancelsTouchesInView = false
    gestureRecognizer.delegate = self
    view.addGestureRecognizer(gestureRecognizer)
    
    /* Optional-bind the searchResult, if not nil (the SearchResult has been successfuly populated with parsed JSON) update the UI */
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
  
  @IBAction func playTapped(_ sender: AnyObject) {
    
    if let _ = URL(string: searchResult.previewURL) {
      playSnippet()
    } else {
      snippetUnavailable()
    }
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
  
  func playSnippet() {
    let playerViewController = AVPlayerViewController()
    present(playerViewController, animated: true, completion: nil)
    
    let url = URL(string: searchResult.previewURL)
    let player = AVPlayer(url: url!) /* it is safe to force unwrap it as this block will never get executed if the url is nil (optional-binded in the playTapped() above) */
    playerViewController.player = player
    player.play()
  }
  
  /* Show the alert to the user when the previewURL is not availabe */
  func snippetUnavailable() {
    let alert = UIAlertController(title: nil,
                                  message: "Snippet unavailable for this track. Please try something else.",
                                  preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: { _ in
      self.close() /* dismiss the popupView once the user presses ok */
    })
    
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
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








