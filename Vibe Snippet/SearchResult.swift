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
  var smallImageURL = ""
  var largeImageURL = ""
  var trackPopularity = 0
  var previewURL = ""
  var spotifyURLForArtist = ""
  var spotifyURLForAlbum = ""
  var spotifyURLForPlaylist = ""
  var numberOfTracks = 0
  var playlistOwner = ""
  var followers = 0
  var artistPopularity = 0
  var genres: [String] = []
}

// Sort the search results alphabetically - by the track name
func tracksOrderedAscending(lhs: SearchResult, rhs: SearchResult) -> Bool {
  return lhs.trackName.localizedStandardCompare(rhs.trackName) == .orderedAscending
}

// Sort the search results in a decreasing order - by the number of followers (the most first)
func > (lhs: SearchResult, rhs: SearchResult) -> Bool {
  return lhs.followers > rhs.followers
}

// Sort the search results alphabetically - by the album name
func albumsOrderedAscending(lhs: SearchResult, rhs: SearchResult) -> Bool {
  return lhs.albumName.localizedStandardCompare(rhs.albumName) == . orderedAscending
}

// Sort the search results alphabetically - by the playlist name
func playlistsOrderedAscending(lhs: SearchResult, rhs: SearchResult) -> Bool {
  return lhs.playlistName.localizedStandardCompare(rhs.playlistName) == .orderedAscending
}











