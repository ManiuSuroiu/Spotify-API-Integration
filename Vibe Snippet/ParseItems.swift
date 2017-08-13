//
//  Parse.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 09/08/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

// MARK: Parse 'items' array according to their type (track, artist, album or playlist). Contains the logic to parse the low-level JSON objects necessary to fill SearchResult's properties

class ParseItems {
  
  // MARK: Parse 'tracks' JSON. Iterate through the 'items' array, get the values from each dictionary and put them into the SearchResult's properties
  func parse(tracks array: [[String: AnyObject]]) -> [SearchResult] {
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
        
        /* Get the last dictionary from the array (this is the dictionary that contains the URL for the image with the smallest size - to display in the table view) */
        let smallImageURLDictionary = imagesArray.last,
        /* Get the small image url */
        let smallImageURL = smallImageURLDictionary[Constants.SpotifyResponseKeys.ImageURL] as? String,
        /* Get the first dictionary from the array (this is the dictionary that contains the URL for the image with the largest size - to display in the pop-up view) */
        let largeImageURLDictionary = imagesArray.first,
        /* Get the large image url */
        let largeImageURL = largeImageURLDictionary[Constants.SpotifyResponseKeys.ImageURL] as? String {
        searchResult.smallImageURL = smallImageURL
        searchResult.largeImageURL = largeImageURL
      }
      searchResults.append(searchResult)
    }
    return searchResults
  }
  
  // MARK: Parse 'artists' JSON. Iterate through the 'items' array, get the values from each dictionary and put them into the SearchResult's properties
  func parse(artists array: [[String: AnyObject]]) -> [SearchResult] {
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
        searchResult.smallImageURL = imageURL
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
  
  // MARK: Parse 'albums' JSON. Iterate through the 'items' array, get the values from each dictionary and put them into the SearchResult's properties
  func parse(albums array: [[String: AnyObject]]) -> [SearchResult] {
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
        searchResult.smallImageURL = imageURL
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
  
  // MARK: Parse 'playlists' JSON. Iterate through the 'items' array, get the values from each dictionary and put them into the SearchResult's properties
  func parse(playlists array: [[String: AnyObject]]) -> [SearchResult] {
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
        searchResult.smallImageURL = imageURL
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






















