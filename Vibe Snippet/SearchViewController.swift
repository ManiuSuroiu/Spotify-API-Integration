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
  
  // MARK: Properties
  let search = Search()
  
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
  
  // MARK: Show a network error alert to the user
  func showNetworkError() {
    let alert = UIAlertController(title: "Whoops...",
                                  message: "There was an error reading from Spotify. Please try again.",
                                  preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(action)
    
    present(alert, animated: true, completion: nil)
  }
  
  // MARK: Perform a search - needs to be called from two different places, searchBarSearchButtonClicked() and the segmentChanged() IBAction so when the user switches to a different type (ie 'album' or 'playlist') the app performs a new search with the specified type in the URL
  func performSearch() {
    
    /* Convert the selected segment index into a Category value */
    if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
      search.performSearch(text: searchBar.text!, category: category) { searchComplete in
        
        /* Use the completion handler's boolean value to determine whether the search was successful or not. If its value is 'false' show the network error to the user */
        if !searchComplete {
          self.showNetworkError()
        }
        self.tableView.reloadData()
      }
      tableView.reloadData()
      searchBar.resignFirstResponder()
    }
  }
  
  // MARK: prepare(for:sender:) Configure the view controller corresponding to its segue identifier when the segue is being triggered from tableView(didSelectRowAt)
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if let identifier = segue.identifier {
      
      switch identifier {
      
      case Constants.SegueIdentifiers.TrackSegue:
        let trackDetailViewController = segue.destination as! TrackDetailViewController
        let indexPath = sender as! IndexPath
        let searchResult = search.searchResults[indexPath.row]
        trackDetailViewController.searchResult = searchResult
      case Constants.SegueIdentifiers.ArtistSegue:
        let artistDetailViewController = segue.destination as! ArtistDetailViewController
        let indexPath = sender as! IndexPath
        let searchResult = search.searchResults[indexPath.row]
      default:
        break
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
    if search.isLoading {
      return 1
    } else if !search.hasSearched {
      return 0
    } else if search.searchResults.count == 0 {
      return 1
    } else {
      return search.searchResults.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    // Handling the three possible scenarios:
    /* 1. Returns one cell, the LoadingCell, showing the user that data is being retrieved from the Spotify server */
    if search.isLoading {
      let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellIdentifiers.LoadingCell, for: indexPath)
      let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
      spinner.startAnimating()
      return cell
      
    /* 2. Also returns one cell, the NothingFoundCell, showing the user that no data matches her search */
    } else if search.searchResults.count == 0 {
      return tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellIdentifiers.NothingFoundCell, for: indexPath)
    
      /* 3.Returns cells populated with searchResult objects, upon a successful search */
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellIdentifiers.SearchResultCell, for: indexPath) as! SearchResultCell
      let searchResult = search.searchResults[indexPath.row]
      
      if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
        cell.configure(for: searchResult, category: category)
      }
      return cell
    }
  }
}

// MARK: UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
      
      switch category {
      case .tracks:
        performSegue(withIdentifier: Constants.SegueIdentifiers.TrackSegue, sender: indexPath)
      case .artists:
        performSegue(withIdentifier: Constants.SegueIdentifiers.ArtistSegue, sender: indexPath)
      case .albums:
        performSegue(withIdentifier: Constants.SegueIdentifiers.AlbumSegue, sender: indexPath)
      case .playlists:
        performSegue(withIdentifier: Constants.SegueIdentifiers.PlaylistSegue, sender: indexPath)
      }
    }
  }
  
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    if search.searchResults.count == 0 || search.isLoading {
      return nil
    } else {
      return indexPath
    }
  }
}












