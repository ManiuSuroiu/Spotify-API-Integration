//
//  ParseAlbums.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 08/08/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

class ParseAlbums {
  
  var searchResults: [SearchResult] = []
  
  // MARK: Parse the top-level dictionary returned by parse(json) and return the array of dictionaries where all the data sits
  func parse(dictionary: [String: AnyObject]) -> [[String: AnyObject]]? {
    
    /* GUARD: Get the top-level dictionary */
    guard let albumsDictionary = dictionary[Constants.SpotifyResponseKeys.Albums] as? [String: AnyObject] else {
      print("Could not find key '\(Constants.SpotifyResponseKeys.Albums)' in: '\(dictionary)'")
      return nil
    }
    
    /* GUARD: Get the 'items' array containing info for each artist (in form of dictionaries) */
    guard let itemsArray = albumsDictionary[Constants.SpotifyResponseKeys.Items] as? [[String: AnyObject]] else {
      print("Could not find key '\(Constants.SpotifyResponseKeys.Items)' in: '\(albumsDictionary)'")
      return nil
    }
    return itemsArray
  }
  
  // MARK: Iterate through the 'items' array, get the values from each dictionary and put them into the SearchResult's properties
  func parse(items array: [[String: AnyObject]]) -> [SearchResult] {
    var searchResults: [SearchResult] = []
    
    for resultDict in array {
      
      let searchResult = SearchResult()
      
      /* Get the 'artists' array, where the name of artist is located */
      if let artistsArray = resultDict[Constants.SpotifyResponseKeys.Artists] as? [[String: AnyObject]],
        /* Get the dictionary inside the array (there should be only one or two) */
        let dict = artistsArray.last,
        /* Get the artist name */
        let artistName = dict[Constants.SpotifyResponseKeys.Name] as? String {
        searchResult.artistName = artistName
      }
      
      /* Get the 'album' name */
      if let albumName = resultDict[Constants.SpotifyResponseKeys.Name] as? String {
        searchResult.albumName = albumName
      }
      
      /* Get the 'images' array of dictionaries which contain urls to images of different resolutions */
      if let imagesArray = resultDict[Constants.SpotifyResponseKeys.Images] as? [[String: AnyObject]],
        /* Get the last dictionary in the array (that contains the url of the image with smallest resolution) */
        let imageURLDictionary = imagesArray.last,
        /* Get the URL for that image */
        let imageURL = imageURLDictionary[Constants.SpotifyResponseKeys.ImageURL] as? String {
        searchResult.imageURL = imageURL
      }
      
      /* Get the external url dictionary */
      if let externalURL = resultDict[Constants.SpotifyResponseKeys.ExternalURL] as? [String: AnyObject],
        /* Get the Spotify URL from the dictionary */
        let spotifyURL = externalURL[Constants.SpotifyResponseKeys.SpotifyURL] as? String {
        searchResult.spotifyURLForAlbum = spotifyURL
      }
      searchResults.append(searchResult)
    }
    return searchResults
  }
}























