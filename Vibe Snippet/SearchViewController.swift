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
  let searchQuery = SearchQuery()
  var landscapeViewController: LandscapeViewController?
  
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
    let alert = UIAlertController(title: nil,
                                  message: "The Internet connection appears to be offline.",
                                  preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(action)
    
    present(alert, animated: true, completion: nil)
  }
  
  // MARK: Perform a search - needs to be called from two different places, searchBarSearchButtonClicked() and the segmentChanged() IBAction so when the user switches to a different type (ie 'album' or 'playlist') the app performs a new search with the specified type in the URL
  func performSearch() {
    
    /* Convert the selected segment index into a Category value */
    if let category = SearchQuery.Category(rawValue: segmentedControl.selectedSegmentIndex) {
      searchQuery.performSearch(text: searchBar.text!, category: category) { searchComplete in
        
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
        let searchResult = searchQuery.searchResults[indexPath.row]
        trackDetailViewController.searchResult = searchResult
     
      case Constants.SegueIdentifiers.ArtistSegue:
        let artistDetailViewController = segue.destination as! ArtistDetailViewController
        let indexPath = sender as! IndexPath
        let searchResult = searchQuery.searchResults[indexPath.row]
        artistDetailViewController.searchResult = searchResult
      
      case Constants.SegueIdentifiers.AlbumSegue:
        let albumDetailViewController = segue.destination as! AlbumDetailViewController
        let indexPath = sender as! IndexPath
        let searchResult = searchQuery.searchResults[indexPath.row]
        albumDetailViewController.searchResult = searchResult
      
      case Constants.SegueIdentifiers.PlaylistSegue:
        let playlistDetailViewController = segue.destination as! PlaylistDetailViewController
        let indexPath = sender as! IndexPath
        let searchResult = searchQuery.searchResults[indexPath.row]
        playlistDetailViewController.searchResult = searchResult
      
      default:
        break
      }
    }
  }
  
  // MARK: willTransition(to:with:) invoked when the device is flipped over
  override func willTransition(to newCollection: UITraitCollection,
                               with coordinator: UIViewControllerTransitionCoordinator) {
    super.willTransition(to: newCollection, with: coordinator)
    
    switch newCollection.verticalSizeClass {
    case .compact:
      showLandscape(with: coordinator)
    case .regular, .unspecified:
      hideLandscape(with: coordinator)
    }
  }
  
  // MARK: showLandscape(with:) - instantiate LandscapeViewController programmatically by adding it to SearchViewController as a child
  func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
    
    /* Ensure the app doesn't instantiate a second landscape when the user is already looking at one */
    guard landscapeViewController == nil else { return }
    
    /* Instantiate the LandscapeViewController from storyboards by its identifier (no segue) */
    landscapeViewController = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
    
    /* Optional-bind the landscapeViewController */
    if let controller = landscapeViewController {
      /* Set the size and position of the new VC  - SearchViewController's view is the superview thus the frame of the landscape must be set equal to the SearchViewController's bounds */
      controller.view.frame = view.bounds
      /* Make the view completely transparent as the screen begins rotating */
      controller.view.alpha = 0
      /* Add the landscape controller's view as a subview - this places it on top of table view, search bar and segmented control */
      view.addSubview(controller.view)
      /* Tell SearchViewController that the LandscapeViewController is now managing that part of the screen */
      addChildViewController(controller)
      
      coordinator.animate(alongsideTransition: { _ in
        controller.view.alpha = 1
        self.searchBar.resignFirstResponder()
        /* Dismiss the detail pop-up (if there is one present) as the screen rotates towards landscape */
        if self.presentedViewController != nil {
          self.dismiss(animated: true, completion: nil)
        }
      },
                          completion: { _ in
        /* Tell the new view controller that it now has a parent view controller */
        controller.didMove(toParentViewController: self)
      })
    }
  }
  
  // MARK: hideLandscape(with:) - flip back to portrait
  func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
    
    if let controller = landscapeViewController {
      /* The inverse operations of embedding the child view controller (LandscapeViewController) */
      controller.willMove(toParentViewController: self)
      
      coordinator.animate(alongsideTransition: { _ in
        controller.view.alpha = 0
      },
                          completion: { _ in
          controller.view.removeFromSuperview()
          controller.removeFromParentViewController()
          self.landscapeViewController = nil
      })
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
    if searchQuery.isLoading {
      return 1
    } else if !searchQuery.hasSearched {
      return 0
    } else if searchQuery.searchResults.count == 0 {
      return 1
    } else {
      return searchQuery.searchResults.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    // Handling the three possible scenarios:
    /* 1. Returns one cell, the LoadingCell, showing the user that data is being retrieved from the Spotify server */
    if searchQuery.isLoading {
      let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellIdentifiers.LoadingCell, for: indexPath)
      let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
      spinner.startAnimating()
      return cell
      
    /* 2. Also returns one cell, the NothingFoundCell, showing the user that no data matches her search */
    } else if searchQuery.searchResults.count == 0 {
      return tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellIdentifiers.NothingFoundCell, for: indexPath)
    
      /* 3.Returns cells populated with searchResult objects, upon a successful search */
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableViewCellIdentifiers.SearchResultCell, for: indexPath) as! SearchResultCell
      let searchResult = searchQuery.searchResults[indexPath.row]
      
      if let category = SearchQuery.Category(rawValue: segmentedControl.selectedSegmentIndex) {
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
    
    if let category = SearchQuery.Category(rawValue: segmentedControl.selectedSegmentIndex) {
      
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
    if searchQuery.searchResults.count == 0 || searchQuery.isLoading {
      return nil
    } else {
      return indexPath
    }
  }
}












