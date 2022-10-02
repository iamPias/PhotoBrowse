//
//  ServerConfiguration.swift
//  BrowsePhotos
//
//  Created by Pias khan on 10/2/22.
//

import Foundation

struct ServerConfig {
    static let baseURL = "https://api.flickr.com/services/rest/"
    static let imageSearchUrl = String(format: "%@?method=%@&api_key=%@&safe_search=1&format=json&nojsoncallback=1&per_page=%d",
               baseURL, Constants.imageSearchMethod, Constants.API_KEY, Constants.per_page)
}

struct Constants {
    static let API_KEY = "59cd6086d178dd3fd0c775bce4371176"
    static let imageSearchMethod = "flickr.photos.search"
    static let per_page = 40
}
