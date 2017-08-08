//
//  SearchResult.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 22/07/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

class SearchResult {
  
  var trackName = ""
  var albumName = ""
  var artistName = ""
  var playlistName = ""
  var imageURL = ""
  var trackPopularity = 0
  var previewURL = ""
  var spotifyURLForArtist = ""
  var spotifyURLForAlbum = ""
  var spotifyURLForPlaylist = ""
  var numberOfTracks = 0
  var playlistOwner = ""
  var followers = 0
  var artistPopularity = 0
  var genres: [String?] = []
}

// Sort the search results returned by the endpoint alphabetically - by the track name.
func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
  return lhs.trackName.localizedStandardCompare(rhs.trackName) == .orderedAscending
}













