//
//  Constants.swift
//  Vibe Snippet
//
//  Created by Maniu Suroiu on 31/07/2017.
//  Copyright © 2017 Maniu Suroiu. All rights reserved.
//

import UIKit

// MARK: Constants

struct Constants {
  
  // MARK: Authorization Body Parameter
  static let BodyParameter = "grant_type=client_credentials"
  
  // MARK: Client ID Key
  static let ClientID = "ea45394e87614af5b7a2c50dc67ff77d"
  
  // MARK: Client Secret Key
  static let ClientSecret = "53e0bdead8a34e74bd2d6c1cec425dab"
  
  // MARK: Spotify
  struct Spotify {
    static let APIScheme = "https"
    static let APIHost = "api.spotify.com"
    static let ApiPath = "/v1"
  }
  
  // MARK: Methods
  struct Methods {
    static let Search = "/search"
    static let AuthorizationURL = "https://accounts.spotify.com/api/token"
  }
  
  // MARK: Spotify Parameter Keys
  struct SpotifyParameterKeys {
    static let Query = "q"
    static let ItemType = "type"
    static let Limit = "limit"
  }
  
  // MARK: Spotify Parameter Values
  struct SpotifyParameterValues {
    static let Artist = "artist"
    static let Album = "album"
    static let Playlist = "playlist"
    static let Track = "track"
    static let MaximumLimit = "50"
  }
  
  // MARK: Spotify Response Keys
  struct SpotifyResponseKeys {
    static let AccessToken = "access_token"
    static let Tracks = "tracks"
    static let Items = "items"
    static let Artists = "artists"
    static let Albums = "albums"
    static let Playlists = "playlists"
    static let Name = "name"
    static let Followers = "followers"
    static let Total = "total"
    static let Genres = "genres"
    static let Popularity = "popularity"
    static let TrackPreviewURL = "preview_url"
    static let ExternalURL = "external_urls"
    static let SpotifyURL = "spotify"
    static let Album = "album"
    static let PlaylistOwner = "owner"
    static let OwnerName = "display_name"
    static let Images = "images"
    static let ImageURL = "url"
  }
  
  // MARK: Table View Cell Identifiers
  struct TableViewCellIdentifiers {
    static let SearchResultCell = "SearchResultCell"
    static let NothingFoundCell = "NothingFoundCell"
    static let LoadingCell = "LoadingCell"
  }
}













