//
//  SearchResult.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 22/07/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

class SearchResult {
  
  var name = ""
  var artistName = ""
  var imageURL = ""
  var popularity = 0
  var previewURL = ""
}

// Sort the search results returned by the endpoint alphabetically - by the track name.
func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
  return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}













