//
//  LocationPhotos.swift
//  VirtualTourist
//
//  Created by Joab Maldonado on 10/9/22.
//

import Foundation

struct LocationPhotos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [PhotoURL]
}
