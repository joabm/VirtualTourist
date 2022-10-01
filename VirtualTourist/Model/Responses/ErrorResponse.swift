//
//  ErrorResponse.swift
//  VirtualTourist
//
//  Created by Joab Maldonado on 9/27/22.
//

import Foundation

struct ErrorResponse: Codable {
    let stat: String
    let code: Int
    let message: String
}

extension ErrorResponse: LocalizedError {
    var errorDescription: String? {
        return message
    }
}
