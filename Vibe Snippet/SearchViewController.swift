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
  
  // MARK: Properties
  var searchResults: [SearchResult] = []
  var hasSearched = false
  
  let clientID = "ea45394e87614af5b7a2c50dc67ff77d"
  let clientSecret = "53e0bdead8a34e74bd2d6c1cec425dab"
  var accessToken: String?

  
  // MARK: Constants
  struct TableViewCellIdentifiers {
    static let searchResultCell = "SearchResultCell"
    static let nothingFoundCell = "NothingFoundCell"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchBar.becomeFirstResponder()
    tableView.rowHeight = 80
    
    /* Add a 64-point margin at the top of the table view, so the search bar doesn't obscure the first row */
    tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
    
    /* Use the nib SearchResultCell or NothingFoundCell, whichever is appropriate for the situation */
    var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
    
    cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
    tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: Spotify Request Authorization
  
  func spotifyRequestAuthorization(_ completionHandlerForToken: @escaping (_ success: Bool, _ accessToken: String?) -> Void) {
    
    /* TASK: Request authorization in order to obtain an access token needed to access the Spotify WEB API */
    
    /* Configure the request */
    let urlString = "https://accounts.spotify.com/api/token"
    let url = URL(string: urlString)
    
    let request = NSMutableURLRequest(url: url!)
    request.httpMethod = "POST"
    
    let stringBase64 = Data("\(clientID):\(clientSecret)".utf8).base64EncodedString()
    request.addValue("Basic \(stringBase64)", forHTTPHeaderField: "Authorization")
    
    let bodyParameter = "grant_type=client_credentials"
    request.httpBody = bodyParameter.data(using: .utf8)
    
    
    /* Make the request */
    
    let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
      
      /* GUARD: Was there an error? */
      guard (error == nil) else {
        print("There was an error with your request: \(String(describing: error))")
        return
      }
      
      /* Check for a http error and, if there is one, get the status code for that error */
      if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode != 200 {
        print("Your request returned a status code: \(statusCode)")
      }
      
      /* GUARD: Was there any data returned */
      guard let data = data else {
        print("No data was returned by the request!")
        return
      }
      
      /* Parse the data */
      var parsedResult: [String: AnyObject] = [:]
      do {
        parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
      } catch {
        print("Could not parse the data as JSON: '\(data)'")
        return
      }
      
      /* GUARD: Get the access token from dictionary */
      guard let accessTokenString = parsedResult["access_token"] as? String else {
        print("Could not find key 'access_token' in \(parsedResult)")
        return
      }
      completionHandlerForToken(true, accessTokenString)
    }
    task.resume()
  }
  
  // MARK: Search through Spotify
  
  func performSpotifySearch(searchText: String) {
    
    /* TASK: Implement the 'search' Spotify API endpoint to return information about artists, tracks, albums or playlists */
    
    /* Configure the request */
    let escpaedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let urlString = String(format: "https://api.spotify.com/v1/search?q=%@&type=track", escpaedSearchText)
    let url = URL(string: urlString)
    
    let request = NSMutableURLRequest(url: url!)
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
    
    /* Make the request */
    
    let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
      
      guard (error == nil) else {
        print("There was an error with your request: \(String(describing: error))")
        return
      }
      
      /* Check for a http error and, if there is one, get the status code for that error */
      if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode != 200 {
        print("Your request returned a status code: \(statusCode)")
      }
      
      /* GUARD: Was there any data returned */
      guard let data = data else {
        print("No data was returned by the request!")
        return
      }
      
      var parsedResult: [String: AnyObject] = [:]
      do {
        parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
      } catch {
        print("Could not parse the data as JSON: '\(data)'")
        return
      }
      print(parsedResult)
    }
    task.resume()
  }
  
  // MARK: Show network error to the user
  
  func showNetworkError() {
    let alert = UIAlertController(title: "Whoops...",
                                  message: "There was an error reading from Spotify. Please try again.",
                                  preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(action)
    
    present(alert, animated: true, completion: nil)
  }
}

// MARK: UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
    if !searchBar.text!.isEmpty {
      searchBar.resignFirstResponder()
      hasSearched = true
      searchResults = []
      
      spotifyRequestAuthorization() { (success, accessToken) in
        if success {
          self.accessToken = accessToken
          self.performSpotifySearch(searchText: searchBar.text!)
          self.tableView.reloadData()
          return
        }
      }
      showNetworkError()
    }
  }
  
  /* Merges the status bar area with the search bar */
  func position(for bar: UIBarPositioning) -> UIBarPosition {
    return .topAttached
  }
}

// MARK: UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if !hasSearched {
      return 0
    } else if searchResults.count == 0 {
      return 1
    } else {
      return searchResults.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if searchResults.count == 0 {
      return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
      let searchResult = searchResults[indexPath.row]
      cell.trackNameLabel.text = searchResult.name
      cell.artistNameLabel.text = searchResult.artistName
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
    if searchResults.count == 0 {
      return nil
    } else {
      return indexPath
    }
  }
}












