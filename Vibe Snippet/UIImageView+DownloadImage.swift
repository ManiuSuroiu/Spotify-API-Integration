//
//  UIImageView+DownloadImage.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 01/08/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

extension UIImageView {
  
  // MARK: Download an image from a server, by accessing its URL
  func loadImage(url: URL) -> URLSessionDownloadTask {
    let session = URLSession.shared
    
    /* Downloads a file to a temporary location on disk */
    let downloadTask = session.downloadTask(with: url) { [weak self] url, response, error in
                                                          // It is possible that UIImageView no longer exists by the time the image arrives from the server (if the user navigates through the app)
      if error == nil,
        let url = url,
        /* Load the file into a data object and then construct an UIImage from it */
        let data = try? Data(contentsOf: url),
        let image = UIImage(data: data) {
        
        /* Dispatch the image on the main thread */
        DispatchQueue.main.async {
          /* Need to check if the UIImageView still exists (if not there's no more UIImageView to set the image on) */
          if let strongSelf = self {
            strongSelf.image = image
          }
        }
      }
    }
    downloadTask.resume()
    return downloadTask
  }
}












