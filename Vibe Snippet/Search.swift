//
//  Search.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 06/08/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

class Search {
  
  // MARK: Properties
  var searchResults: [SearchResult] = []
  var hasSearched = false
  var isLoading = false
  var accessToken: String?
  
  private var dataTask: URLSessionDataTask?
  
  let parseItems = ParseItems()
  
  enum Category: Int {
    case tracks = 0
    case artists = 1
    case albums = 2
    case playlists = 3
    
    var entityName: String {
      switch self {
      case .tracks: return Constants.SpotifyParameterValues.Track
      case .artists: return Constants.SpotifyParameterValues.Artist
      case .albums: return Constants.SpotifyParameterValues.Album
      case .playlists: return Constants.SpotifyParameterValues.Playlist
      }
    }
  }
  
  // MARK: Spotify Request Authorization
  private func requestAuthorizationFromSpotify(_ completionHandlerForToken: @escaping (_ success: Bool, _ accessToken: String?) -> Void) {
    
    /* TASK: Request authorization in order to obtain an access token needed to access the Spotify WEB API */
    
    /* Configure the request */
    let url = URL(string: Constants.Methods.AuthorizationURL)
    
    let request = NSMutableURLRequest(url: url!)
    request.httpMethod = "POST"
    
    let stringBase64 = Data("\(Constants.ClientID):\(Constants.ClientSecret)".utf8).base64EncodedString()
    request.addValue("Basic \(stringBase64)", forHTTPHeaderField: "Authorization")
    
    let bodyParameter = Constants.BodyParameter
    request.httpBody = bodyParameter.data(using: .utf8)
    
    /* Make the request */
    dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
      
      /* GUARD: Was there an error? */
      guard (error == nil), (error as NSError?)?.code != 999 else {
        print("There was an error with your request: \(String(describing: error))")
        completionHandlerForToken(false, nil)
        return
      }
      
      /* GUARD: Did the status code returned a successful 200 response? */
      guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 200 else {
        print("Your request returned  a status code other than 200!")
        completionHandlerForToken(false, nil)
        return
      }
      
      /* GUARD: Was there any data returned? */
      guard let jsonData = data else {
        print("No data was returned by the request!")
        completionHandlerForToken(false, nil)
        return
      }
      
      /* GUARD: Get the top-level dictionary where the 'access token' sits */
      guard let jsonDictionary = self.parse(json: jsonData) else {
        print("Could not parse the data as JSON: \(String(describing: data))")
        completionHandlerForToken(false, nil)
        return
      }
      
      /* Get the access token from dictionary */
      guard let accessTokenString = jsonDictionary[Constants.SpotifyResponseKeys.AccessToken] as? String else {
        print("Could not find key '\(Constants.SpotifyResponseKeys.AccessToken)' in '\(jsonDictionary)'")
        completionHandlerForToken(false, nil)
        return
      }
      completionHandlerForToken(true, accessTokenString)
    }
    dataTask?.resume()
  }
  
  // MARK: Convenience method to help construct the URL
  private func spotifyURLFromParameters(_ parameters: [String: AnyObject]) -> URL {
    
    var components = URLComponents()
    components.scheme = Constants.Spotify.APIScheme
    components.host = Constants.Spotify.APIHost
    components.path = Constants.Spotify.ApiPath + Constants.Methods.Search
    components.queryItems = [URLQueryItem]()
    
    for (key, value) in parameters {
      let queryItem = URLQueryItem(name: key, value: "\(value)")
      components.queryItems!.append(queryItem)
    }
    return components.url!
  }
  
  // MARK: Search through Spotify
  private func performSpotifySearch(searchText: String, category: Category, completionHandlerForSearch: @escaping (_ success: Bool) -> Void) {
    
    /* TASK: Implement the 'search' Spotify API endpoint to return information about artists, tracks, albums or playlists */
    
    /* Construct the URL necessary to perform a search */
    let entityName = category.entityName
    
    let methodParameters = [
      Constants.SpotifyParameterKeys.Query: searchText,
      Constants.SpotifyParameterKeys.ItemType: entityName,
      Constants.SpotifyParameterKeys.Limit: Constants.SpotifyParameterValues.MaximumLimit
    ]
    
    let url = spotifyURLFromParameters(methodParameters as [String: AnyObject])
    
    /* Configure the request */
    let request = NSMutableURLRequest(url: url)
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
    
    /* Make the request */
    dataTask = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
      
      /* GUARD: Was there an error? */
      guard (error == nil) else {
        print("There was an error with your request: \(String(describing: error))")
        completionHandlerForSearch(false)
        return
      }
      
      /* Did the status code returned a successful 200 response? */
      if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 200,
        
        /* If yes unwrap the data, call the parse(json:) on it to get the top level dictionary */
        let jsonData = data,
        let jsonDictionary = self.parse(json: jsonData),
        
        /* Call parse(dictionary:) on the top level dictionary to get the 'items' array where all the necessary data to populate the UI sits */
        let itemsArray = self.parse(dictionary: jsonDictionary, category: category) {
        
        /* Determine which array to parse (tracks, artists, albums, playlists) */
        switch category {
        
        /* Parse the items array corresponding to the specified category and assign the objects obtained to searchResults properties. Sort the search alphabetically (by the track name). Set the completion handler to true */
        case .tracks:
          self.searchResults = self.parseItems.parse(tracks: itemsArray)
          self.searchResults.sort(by: tracksOrderedAscending(lhs:rhs:))
        
        case .artists:
          self.searchResults = self.parseItems.parse(artists: itemsArray)
          self.searchResults.sort(by: >)
          
        case .albums:
          self.searchResults = self.parseItems.parse(albums: itemsArray)
          self.searchResults.sort(by: albumsOrderedAscending(lhs:rhs:))
          
        case .playlists:
          self.searchResults = self.parseItems.parse(playlists: itemsArray)
          self.searchResults.sort(by: playlistsOrderedAscending(lhs:rhs:))
        }
        completionHandlerForSearch(true)
        
        /* If any of the above fails set the completion handler boolean value to false */
      } else { completionHandlerForSearch(false) }
    }
    dataTask?.resume()
  }
  
  // MARK: Parse the JSON
  private func parse(json data: Data) -> [String: AnyObject]? {
    do {
      return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
    } catch {
      print("Could not parse the data as JSON: '\(data)'")
      return nil
    }
  }
  
  // MARK: Parse the top-level dictionary returned by parse(json) and return the array of dictionaries where all the data sits
  func parse(dictionary: [String: AnyObject], category: Category) -> [[String: AnyObject]]? {
    
    /* Determine which top-level dictionary to parse */
    switch category {
      
    case .tracks:
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
      
    case .artists:
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
      
    case .albums:
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
      
    case .playlists:
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
  }
  
  // MARK: Perform a search - chain the completion handlers of requestAuthorizationFromSpotify() and performSpotifySearch(with:) so they run one after the other
  func performSearch(text: String, category: Category, completion: @escaping (_ searchComplete: Bool) -> Void) {
    
    /* Checks for the search bar not to be empty */
    if !text.isEmpty {
      
      /* Cancels any previous requests so the user won't be able to start two simultaneous requests */
      dataTask?.cancel()
      isLoading = true
      hasSearched = true
      searchResults = []
      
      /* Request an access token from Spotify, if obtained assign it to the 'accessToken' instance variable and use it to perform a search through Spotify */
      requestAuthorizationFromSpotify() { (success, accessToken) in
        
        if success {
          
          self.accessToken = accessToken
          
          self.performSpotifySearch(searchText: text, category: Search.Category(rawValue: category.rawValue)!) { success in
            
            if success {
              /* Update the UI on the main thread: hide the activity indicator cell and set the completion handler to true */
              DispatchQueue.main.async {
                self.isLoading = false
                completion(true)
              }
            }
          }
        } else {
          /* If the request authorization fails, hide the activity indicator cell, reload the data in the table and show the user the error message */
          DispatchQueue.main.async {
            self.hasSearched = false
            self.isLoading = false
            completion(false)
          }
        }
      }
    }
  }
}




























