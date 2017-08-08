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
  
  let parseTracks = ParseTracks()
  let parseArtists = ParseArtists()
  let parseAlbums = ParseAlbums()
  let parsePlaylists = ParsePlaylists()
  
  // MARK: Spotify Request Authorization
  func requestAuthorizationFromSpotify(_ completionHandlerForToken: @escaping (_ success: Bool, _ accessToken: String?) -> Void) {
    
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
  func spotifyURLFromParameters(_ parameters: [String: AnyObject]) -> URL {
    
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
  
  // MARK: Construct the URL necessary to perform a search. Call it from performSpotifySearch()
  func spotifyURL(searchText: String, category: Int) -> URL {
    
    var entityName: String
    
    switch category {
    case 0: entityName = Constants.SpotifyParameterValues.Track
    case 1: entityName = Constants.SpotifyParameterValues.Artist
    case 2: entityName = Constants.SpotifyParameterValues.Album
    case 3: entityName = Constants.SpotifyParameterValues.Playlist
    default: entityName = ""
    }
    
    let methodParameters = [
      Constants.SpotifyParameterKeys.Query: searchText,
      Constants.SpotifyParameterKeys.ItemType: entityName,
      Constants.SpotifyParameterKeys.Limit: Constants.SpotifyParameterValues.MaximumLimit
    ]
    
    let url = spotifyURLFromParameters(methodParameters as [String: AnyObject])
    return url
  }
  
  // MARK: Search through Spotify
  func performSpotifySearch(with url: URL, completionHandlerForSearch: @escaping (_ success: Bool) -> Void) {
    
    /* TASK: Implement the 'search' Spotify API endpoint to return information about artists, tracks, albums or playlists */
    
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
        let itemsArray = self.parsePlaylists.parse(dictionary: jsonDictionary) {
        
        /* Call parse(items:) on the items array to get the data needed and assign it to searchResults properties. Sort the search alphabetically (by the track name). */
        self.searchResults = self.parsePlaylists.parse(items: itemsArray)
        self.searchResults.sort(by: <)
        
        print("Results: \(self.searchResults.count)")
        completionHandlerForSearch(true)
        
        /* If any of the above fails set the completion handler boolean value to false */
      } else { completionHandlerForSearch(false) }
    }
    dataTask?.resume()
  }
  
  // MARK: Parse the JSON
  func parse(json data: Data) -> [String: AnyObject]? {
    do {
      return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
    } catch {
      print("Could not parse the data as JSON: '\(data)'")
      return nil
    }
  }
  
  // MARK: Perform a search - chain the completion handlers of requestAuthorizationFromSpotify() and performSpotifySearch(with:) so they run one after the other
  func performSearch(text: String, category: Int, completion: @escaping (_ searchComplete: Bool) -> Void) {
    
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
          print("Token: \(String(describing: accessToken))")
          self.performSpotifySearch(with: self.spotifyURL(searchText: text, category: category)) { success in
            
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




























