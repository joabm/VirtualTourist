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
    let total: Int
    let photo: [Photos]
}

struct Photos: Codable {
    let id: Int
    let owner: String
    let secret: String
    let server: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    
    func photoURL() -> String {
        return "https://live.staticflickr.com/\(server)/\(id)_\(secret).jpg"
    }
}
