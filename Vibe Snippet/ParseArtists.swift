//
//  ParseArtists.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 07/08/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

// MARK: Parse code when the user is searching for artists

class ParseArtists {
  
  var searchResults: [SearchResult] = []
  
  // MARK: Parse the top-level dictionary returned by parse(json) and return the array of dictionaries where all the data sits
  func parse(dictionary: [String: AnyObject]) -> [[String: AnyObject]]? {
    
    /* GUARD: Get the top-level dictionary */
    guard let artistsDictionary = dictionary[Constants.SpotifyResponseKeys.Artists] as? [String: AnyObject] else {
      print("Could not find key '\(Constants.SpotifyResponseKeys.Artists)' in: '\(dictionary)'")
      return nil
    }
    
    /* GUARD: Get the 'items' array containing info for each artist (in form of dictionaries) */
    guard let itemsArray = artistsDictionary[Constants.SpotifyResponseKeys.Items] as? [[String: AnyObject]] else {
      print("Could not find key '\(Constants.SpotifyResponseKeys.Items)' in: '\(artistsDictionary)'")
      return nil
    }
    return itemsArray
  }
  
  // MARK: Iterate through the 'items' array, get the values from each dictionary and put them into the SearchResult's properties
  func parse(items array: [[String: AnyObject]]) -> [SearchResult] {
    var searchResults: [SearchResult] = []
    
    for resultDict in array {
      
      let searchResult = SearchResult()
      
      /* Get the artist name */
      if let artistName = resultDict[Constants.SpotifyResponseKeys.Name] as? String {
        searchResult.artistName = artistName
      }
      
      /* Get the followers dictionary for that particular artist */
      if let followers = resultDict[Constants.SpotifyResponseKeys.Followers] as? [String: AnyObject],
        /* Get the number of followers */
        let totalFollowers = followers[Constants.SpotifyResponseKeys.Total] as? Int {
        searchResult.followers = totalFollowers
      }
      
      /* Get the popularity index of the artist */
      if let popularity = resultDict[Constants.SpotifyResponseKeys.Popularity] as? Double {
        searchResult.artistPopularity = Int(popularity)
      }
      
      /* Get the genres array */
      if let genres = resultDict[Constants.SpotifyResponseKeys.Genres] as? [String?] {
        /* Iterate through the array and append each genre to the genres array property of SearchResult */
        for genre in genres { searchResult.genres.append(genre) }
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
        searchResult.spotifyURLForArtist = spotifyURL
      }
      searchResults.append(searchResult)
    }
    return searchResults
  }

}














