//
//  ArtistDetailViewController.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 13/08/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

class ArtistDetailViewController: UIViewController {
  
  @IBOutlet weak var popupView: UIView!
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var numberOfFollowersLabel: UILabel!
  @IBOutlet weak var genreLabel: UILabel!
  @IBOutlet weak var takeMeToSpotify: UIButton!
  
  var searchResult: SearchResult!
  private var downloadTask: URLSessionDownloadTask?
  
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
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func openSpotify() {
    if let url = URL(string: searchResult.spotifyURLForArtist) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
  
  func updateUI() {
    artistNameLabel.text = searchResult.artistName
    numberOfFollowersLabel.text = "\(searchResult.followers)"
    
    if searchResult.genres.isEmpty {
      genreLabel.text = "Unknown"
    } else {
      genreLabel.text = String(format: "%@", searchResult.genres.first!).capitalized
    }
    
    if let imageURL = URL(string: searchResult.largeImageURL) {
      downloadTask = artworkImageView.loadImage(url: imageURL)
    }
  }
}

// MARK: UIVieControllerTransitioningDelegate

extension ArtistDetailViewController: UIViewControllerTransitioningDelegate {
  
  func presentationController(forPresented presented: UIViewController,
                              presenting: UIViewController?,
                              source: UIViewController) -> UIPresentationController? {
    return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
  }
}

// MARK: UIGestureRecognizerDelegate

extension ArtistDetailViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                         shouldReceive touch: UITouch) -> Bool {
    return (touch.view === self.view)
  }
}




