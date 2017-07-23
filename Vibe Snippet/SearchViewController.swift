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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    /* Add a 64-point margin at the top of the table view, so the search bar doesn't obscure the first row */
    tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

// MARK: UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    
    let searchResult = SearchResult()
    
    if searchBar.text! != "justin bieber" {
      for i in 0...2 {
        searchResult.name = String(format: "Fake Result %d for", i)
        searchResult.artistName = searchBar.text!
        searchResults.append(searchResult)
      }
    }
    hasSearched = true
    tableView.reloadData()
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
    let cellIdentifier = "SearchResultCell"
    
    var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
    
    if cell == nil {
      cell = UITableViewCell(style: .subtitle , reuseIdentifier: cellIdentifier)
    }
    
    if searchResults.count == 0 {
      cell.textLabel!.text = "(Nothing found)"
      cell.detailTextLabel!.text = ""
    } else {
      let searchResult = searchResults[indexPath.row]
      cell.textLabel!.text = searchResult.name
      cell.detailTextLabel!.text = searchResult.artistName
    }
    return cell
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












