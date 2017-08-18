//
//  AlbumDetailViewController.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 13/08/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

class AlbumDetailViewController: UIViewController {
  
  @IBOutlet weak var popupView: UIView!
  @IBOutlet weak var artworkImageView: UIImageView!
  @IBOutlet weak var albumNameLabel: UILabel!
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var takeMeToSpotify: UIButton!
  
  var searchResult: SearchResult!
  var downloadTask: URLSessionDownloadTask?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.tintColor = UIColor(red: 10/255, green: 150/255, blue: 255/255, alpha: 1)

    popupView.layer.cornerRadius = 10
    
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
    if let url = URL(string: searchResult.spotifyURLForAlbum) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
  
  func updateUI() {
    albumNameLabel.text = searchResult.albumName
    artistNameLabel.text = searchResult.artistName
    
    if let imageURL = URL(string: searchResult.largeImageURL) {
      downloadTask = artworkImageView.loadImage(url: imageURL)
    }

  }
}

// MARK: UIViewControllerTransitioningDelegate

extension AlbumDetailViewController: UIViewControllerTransitioningDelegate {
  
  func presentationController(forPresented presented: UIViewController,
                              presenting: UIViewController?,
                              source: UIViewController) -> UIPresentationController? {
    return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
  }
}

// MARK: UIGestureRecognizerDelegate

extension AlbumDetailViewController: UIGestureRecognizerDelegate {
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                         shouldReceive touch: UITouch) -> Bool {
    return (touch.view === self.view)
  }
}












