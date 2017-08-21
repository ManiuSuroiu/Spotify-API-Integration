//
//  SearchResultCell.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 23/07/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {
  
  // MARK: Outlets for 'tracks' search
  @IBOutlet weak var artistNameLabel: UILabel!
  @IBOutlet weak var trackNameLabel: UILabel!
  
  // MARK: Outlets for 'artists' search
  @IBOutlet weak var artistName: UILabel!
  @IBOutlet weak var numberOfFollowersLabel: UILabel!
  
  // MARK: Outlet for 'albums' search
  @IBOutlet weak var albumNameLabel: UILabel!
  
  // MARK: Outlets for 'playlists' search
  @IBOutlet weak var playlistNameLabel: UILabel!
  @IBOutlet weak var numberOfTracksLabel: UILabel!
  
  // MARK: UIImageView outlet, available for all four types of search
  @IBOutlet weak var artworkImageView: UIImageView!
  
  private var downloadTask: URLSessionDownloadTask?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    let selectedView = UIView(frame: CGRect.zero)
    selectedView.backgroundColor = UIColor(red: 10/255, green: 150/255, blue: 255/255, alpha: 0.5)
    selectedBackgroundView = selectedView
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    downloadTask?.cancel()
    downloadTask = nil
  }
  
  // MARK: Configure the cell's labels according to the type of search. Call it from UITableViewDataSource method tableView(cellForRowAt:) in SearchViewController
  func configure(for searchResult: SearchResult, category: SearchQuery.Category) {
    
    /* Match the appropriate case to the selected integer value of the segmentedControl */
    switch category {
    case .tracks:
      trackNameLabel.text = searchResult.trackName
      artistNameLabel.text = String(format: "%@ (Popularity: %d)", searchResult.artistName, searchResult.trackPopularity)
        
    case .artists:
      artistName.text = searchResult.artistName
      numberOfFollowersLabel.text = String(format: "Followers: %d", searchResult.followers)
      
    case .albums:
      albumNameLabel.text = searchResult.albumName
      artistNameLabel.text = searchResult.artistName
        
    case .playlists:
      playlistNameLabel.text = searchResult.playlistName
      numberOfTracksLabel.text = String(format: "Tracks: %d", searchResult.numberOfTracks)
    }
    
    /* Set the imageView to the image downloaded from the server */
    artworkImageView.image = UIImage(named: "Placeholder")
    if let imageURL = URL(string: searchResult.smallImageURL) {
      downloadTask = artworkImageView.loadImage(url: imageURL)
    }
  }
}
