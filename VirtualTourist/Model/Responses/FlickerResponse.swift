//
//  FlickerResponse.swift
//  VirtualTourist
//
//  Created by Joab Maldonado on 9/26/22.
//

import Foundation

struct FlickrResponse: Codable {
    let photos: FlickrPhotos
    let stat: String
}

struct FlickrPhotos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [FlickrPhoto]
}

struct FlickrPhoto: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}

