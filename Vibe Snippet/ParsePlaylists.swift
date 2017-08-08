//
//  ParsePlaylists.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 08/08/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

class ParsePlaylists {
  
  var searchResults: [SearchResult] = []
  
  // MARK: Parse the top-level dictionary returned by parse(json) and return the array of dictionaries where all the data sits
  func parse(dictionary: [String: AnyObject]) -> [[String: AnyObject]]? {
    
    /* GUARD: Get the top-level dictionary */
    guard let playlistsDictionary = dictionary[Constants.SpotifyResponseKeys.Playlists] as? [String: AnyObject] else {
      print("Could not find key '\(Constants.SpotifyResponseKeys.Playlists)' in: '\(dictionary)'")
      return nil
    }
    
    /* GUARD: Get the 'items' array containing info for each artist (in form of dictionaries) */
    guard let itemsArray = playlistsDictionary[Constants.SpotifyResponseKeys.Items] as? [[String: AnyObject]] else {
      print("Could not find key '\(Constants.SpotifyResponseKeys.Items)' in: '\(playlistsDictionary)'")
      return nil
    }
    return itemsArray
  }
  
  // MARK: Iterate through the 'items' array, get the values from each dictionary and put them into the SearchResult's properties
  func parse(items array: [[String: AnyObject]]) -> [SearchResult] {
    var searchResults: [SearchResult] = []
    
    for resultDict in array {
      
      let searchResult = SearchResult()
      
      /* Get the name of the playlist */
      if let playlistName = resultDict[Constants.SpotifyResponseKeys.Name] as? String {
        searchResult.playlistName = playlistName
      }
      
      /* Get the external url dictionary */
      if let externalURL = resultDict[Constants.SpotifyResponseKeys.ExternalURL] as? [String: AnyObject],
        /* Get the Spotify URL from the dictionary */
        let spotifyURL = externalURL[Constants.SpotifyResponseKeys.SpotifyURL] as? String {
        searchResult.spotifyURLForPlaylist = spotifyURL
      }
      
      /* Get the 'images' array of dictionaries which contain urls to images of different resolutions */
      if let imagesArray = resultDict[Constants.SpotifyResponseKeys.Images] as? [[String: AnyObject]],
        /* Get the last dictionary in the array (that contains the url of the image with smallest resolution) */
        let imageURLDictionary = imagesArray.last,
        /* Get the URL for that image */
        let imageURL = imageURLDictionary[Constants.SpotifyResponseKeys.ImageURL] as? String {
        searchResult.imageURL = imageURL
      }
      
      /* Get the 'tracks' dictionary to extract the number of tracks in the playlist */
      if let tracks = resultDict[Constants.SpotifyResponseKeys.Tracks] as? [String: AnyObject],
        /* Get the number of tracks */
        let totalTracks = tracks[Constants.SpotifyResponseKeys.Total] as? Int {
        searchResult.numberOfTracks = totalTracks
      }
      
      /* Get the owner of the playlist dictionary */
      if let owner = resultDict[Constants.SpotifyResponseKeys.PlaylistOwner] as? [String: AnyObject],
        /* Get the owner name */
        let ownerName = owner[Constants.SpotifyResponseKeys.OwnerName] as? String {
        searchResult.playlistOwner = ownerName
      }
      searchResults.append(searchResult)
    }
    return searchResults
  }
}



















