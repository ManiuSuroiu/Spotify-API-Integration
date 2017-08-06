//
//  ViewController.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 19/07/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
  
  // MARK: IBOutlets
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  
  // MARK: Instance Variables
  var searchResults: [SearchResult] = []
  var hasSearched = false
  var isLoading = false
  var dataTask: URLSessionDataTask?
  var accessToken: String?

  // MARK: IBActions
  @IBAction func segmentChanged(_ sender: UISegmentedControl) {
    performSearch()
  }
  
  // MARK: ViewDidLoad
  override func viewDidLoad() {
    super.viewDidLoad()
    searchBar.becomeFirstResponder()
    tableView.rowHeight = 80
    
    /* Add a 64-point margin at the top of the table view, so the search bar doesn't obscure the first row */
    tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
    
    /* Use the nib SearchResultCell, NothingFoundCell or LoadingCell, whichever is appropriate for the situation */
    var cellNib = UINib(nibName: Constants.TableViewCellIdentifiers.SearchResultCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: Constants.TableViewCellIdentifiers.SearchResultCell)
    
    cellNib = UINib(nibName: Constants.TableViewCellIdentifiers.NothingFoundCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: Constants.TableViewCellIdentifiers.NothingFoundCell)
    
    cellNib = UINib(nibName: Constants.TableViewCellIdentifiers.LoadingCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: Constants.TableViewCellIdentifiers.LoadingCell)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
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
      
      /* Was there an error? */
      guard (error == nil), (error as NSError?)?.code != 999 else {
        print("There was an error with your request: \(String(describing: error))")
        completionHandlerForToken(false, nil)
        return
      }
      
      /* Did the status code returned a successful 200 response? */
      guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode == 200 else {
        print("Your request returned  a status code other than 200!")
        completionHandlerForToken(false, nil)
        return
      }
      
      /* If yes, unwrap the data object for 'data' parameter, call the parse(json:) on it to get the top-level dictionary where the 'access_token' sits */
      guard let jsonData = data else {
        print("No data was returned by the request!")
        completionHandlerForToken(false, nil)
        return
      }
      
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
    
    let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    
    var entityName: String
    
    switch category {
    case 0: entityName = Constants.SpotifyParameterValues.Track
    case 1: entityName = Constants.SpotifyParameterValues.Artist
    case 2: entityName = Constants.SpotifyParameterValues.Album
    case 3: entityName = Constants.SpotifyParameterValues.Playlist
    default: entityName = ""
    }
    
    let methodParameters = [
      Constants.SpotifyParameterKeys.Query: escapedSearchText,
      Constants.SpotifyParameterKeys.ItemType: entityName,
      Constants.SpotifyParameterKeys.Limit: Constants.SpotifyParameterValues.MaximumLimit
    ]
    
    let url = spotifyURLFromParameters(methodParameters as [String: AnyObject])
    return url
  }

  // MARK: Search through Spotify
  
  func performSpotifySearch(_ completionHandlerForSearch: @escaping (_ success: Bool) -> Void) {
    
    /* TASK: Implement the 'search' Spotify API endpoint to return information about artists, tracks, albums or playlists */
    
    /* Configure the request */
    let request = NSMutableURLRequest(url: spotifyURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex))
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
    print("URL: \(spotifyURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex))")
    
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
        let itemsArray = self.parse(dictionary: jsonDictionary) {
        
        /* Call parse(items:) on the items array to get the data needed and assign it to searchResults properties. Sort the search alphabetically (by the track name). */
        self.searchResults = self.parse(items: itemsArray)
        self.searchResults.sort(by: <)
        
        print("Results: \(self.searchResults.count)")
        completionHandlerForSearch(true)
        
        /* Update the UI on the main thread: hide the activity indicator cell and reload all the data from searchResults into the table view */
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
  
  // MARK: Loop through the 'items' array, get the values from each dictionary and put them into the SearchResult's properties
  func parse(items array: [[String: AnyObject]]) -> [SearchResult] {
    var searchResults: [SearchResult] = []
    
    for resultDict in array {
      
      let searchResult = SearchResult()
      /* Get the 'artists' array, where the name of artist is located */
      if let artistsArray = resultDict[Constants.SpotifyResponseKeys.Artists] as? [[String: AnyObject]],
        /* Get the dictionary inside the array (there should be only one in each 'artists' array) */
        let dict = artistsArray.last,
        /* Get the artist name */
        let artistName = dict[Constants.SpotifyResponseKeys.ArtistName] as? String {
          searchResult.artistName = artistName
      }
      
      
      /* Get the track name */
      if let trackName = resultDict[Constants.SpotifyResponseKeys.TrackName] as? String {
        searchResult.name = trackName
      }
      
      /* Get the popularity index of the track */
      if let popularity = resultDict[Constants.SpotifyResponseKeys.TrackPopularity] as? Double {
        searchResult.popularity = Int(popularity)
      }
      
      /* Get the previewURL of the track */
      if let previewURL = resultDict[Constants.SpotifyResponseKeys.TrackPreviewURL] as? String {
        searchResult.previewURL = previewURL
      }
      
      /* Get the 'album' dictionary, where the 'images' array is located */
      if let albumDictionary = resultDict[Constants.SpotifyResponseKeys.Album] as? [String: AnyObject],
        /* Get the 'images' array, where the image URLs are located */
        let imagesArray = albumDictionary[Constants.SpotifyResponseKeys.Images] as? [[String: AnyObject]],
        /* Get the first dictionary from the array (this is the dictionary that contains the URL for the image with the best resolution) */
        let imageURLDictionary = imagesArray.last,
        /* Get the image url */
        let imageURL = imageURLDictionary[Constants.SpotifyResponseKeys.ImageURL] as? String {
        searchResult.imageURL = imageURL
      }
      
      searchResults.append(searchResult)
    }
    return searchResults
  }

  
  // MARK: Show a network error alert to the user
  func showNetworkError() {
    let alert = UIAlertController(title: "Whoops...",
                                  message: "There was an error reading from Spotify. Please try again.",
                                  preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(action)
    
    present(alert, animated: true, completion: nil)
  }
  
  // MARK: Perform a search - necessary because it needs to be called from two different places, searchBarSearchButtonClicked() and the segmentChanged() IBAction so when the user switches to a different type (ie 'album' or 'playlist') the app performs a new search with the specified type in the URL
  func performSearch() {
    
    /* Checks for the search bar not to be empty */
    if !searchBar.text!.isEmpty {
      searchBar.resignFirstResponder()
      
      /* Cancels any previous requests so in case the user has a bad network connection, she won't be able to start two simultaneous requests */
      dataTask?.cancel()
      isLoading = true
      tableView.reloadData()
      
      hasSearched = true
      searchResults = []
      
      /* Request an access token from Spotify, if obtained assign it to the 'accessToken' instance variable and use it to perform a search through Spotify */
      requestAuthorizationFromSpotify() { (success, accessToken) in
        
        if success {
          self.accessToken = accessToken
          
          self.performSpotifySearch() { success in
          
            if success {
              DispatchQueue.main.async {
                self.isLoading = false
                self.tableView.reloadData()
              }
            }
          }
          
        } else {
          DispatchQueue.main.async {
            self.hasSearched = false
            self.isLoading = false
            self.tableView.reloadData()
            self.showNetworkError()
          }
        }
      }
    }
  }
}

// MARK: UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    performSearch()
  }
  
  /* Merges the status bar area with the search bar */
  func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
}

// MARK: UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isLoading {
      return 1
    } else if !hasSearched {
      return 0
    } else if searchResults.count == 0 {
      return 1
    } else {
      return searchResults.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    // Handling the three possible scenarios:
    /* 1. Returns one cell, the LoadingCell, showing the user that data is being retrieved from the Spotify server */
    if isLoading {
      let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellIdentifiers.LoadingCell, for: indexPath)
      let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
      spinner.startAnimating()
      return cell
      
    /* 2. Also returns one cell, the NothingFoundCell, showing the user that no data matches her search */
    } else if searchResults.count == 0 {
      return tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellIdentifiers.NothingFoundCell, for: indexPath)
    
      /* 3.Returns cells populated with searchResult objects, upon a successful search */
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellIdentifiers.SearchResultCell, for: indexPath) as! SearchResultCell
      let searchResult = searchResults[indexPath.row]
      cell.configure(for: searchResult)
      return cell
    }
  }
}

// MARK: UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    if searchResults.count == 0 || isLoading {
      return nil
    } else {
      return indexPath
    }
  }
}












