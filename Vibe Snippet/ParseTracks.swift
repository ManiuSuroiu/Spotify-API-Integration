//
//  ParseTracks.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 07/08/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

//MARK: Parse code when user is searching for tracks

class ParseTracks {
  
  var searchResults: [SearchResult] = []
  
  // MARK: Parse the top-level dictionary returned by parse(json) and return the array of dictionaries where all the data sits
  func parse(dictionary: [String: AnyObject]) -> [[String: AnyObject]]? {
    
    /* GUARD: Top-level dictionary */
    guard let tracksDictionary = dictionary[Constants.SpotifyResponseKeys.Tracks] as? [String: AnyObject] else {
      print("Could not find key '\(Constants.SpotifyResponseKeys.Tracks)' in: '\(dictionary)'")
      return nil
    }
    
    /* GUARD: The 'items' array containing info for each track (in form of dictionaries) */
    guard let itemsArray = tracksDictionary[Constants.SpotifyResponseKeys.Items] as? [[String: AnyObject]] else {
      print("Could not find key '\(Constants.SpotifyResponseKeys.Items)' in: '\(tracksDictionary)'")
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
      
      /* Get the track name */
      if let trackName = resultDict[Constants.SpotifyResponseKeys.Name] as? String {
        searchResult.trackName = trackName
      }
      
      /* Get the popularity index of the track */
      if let popularity = resultDict[Constants.SpotifyResponseKeys.Popularity] as? Double {
        searchResult.trackPopularity = Int(popularity)
      }
      
      /* Get the previewURL of the track */
      if let previewURL = resultDict[Constants.SpotifyResponseKeys.TrackPreviewURL] as? String {
        searchResult.previewURL = previewURL
      }
      
      /* Get the 'album' dictionary, where the 'images' array is located */
      if let albumDictionary = resultDict[Constants.SpotifyResponseKeys.Album] as? [String: AnyObject],
        /* Get the 'images' array, where the image URLs are located */
        let imagesArray = albumDictionary[Constants.SpotifyResponseKeys.Images] as? [[String: AnyObject]],
        /* Get the last dictionary from the array (this is the dictionary that contains the URL for the image with the smallest size) */
        let imageURLDictionary = imagesArray.last,
        /* Get the image url */
        let imageURL = imageURLDictionary[Constants.SpotifyResponseKeys.ImageURL] as? String {
        searchResult.imageURL = imageURL
      }
      searchResults.append(searchResult)
    }
    return searchResults
  }

}















