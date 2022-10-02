//
//  PhotoResponse.swift
//  BrowsePhotos
//
//  Created by Pias khan on 10/2/22.
//

import Foundation

struct PhotoResponse: Decodable {
    var photos: Images
    var stat: String
}
    
struct Images: Decodable {
    var photo: [Photo]
    var page: Int
    var pages: Int
    var perpage: Int
    var total: Int
}
