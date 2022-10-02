//
//  Photo.swift
//  BrowsePhotos
//
//  Created by Pias khan on 10/2/22.
//

import Foundation

struct Photo: Decodable {
    let title: String
    let farm: Int
    let id: String
    let owner: String
    let secret: String
    let server: String
}
