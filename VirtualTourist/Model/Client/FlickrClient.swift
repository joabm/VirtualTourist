//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Joab Maldonado on 9/26/22.
//

import Foundation
import UIKit

class FlickrClient {
    
    struct Auth {
        static let flickrKey = "a5be689d46f4e4d3b4c6a45a6b8602e2"
    }
        
    enum Endpoint {
        
        case queryPhotosList(Double, Double)
        static let baseUrl = "https://www.flickr.com/services/rest/?method=flickr.photos.search&"
                
        var stringValue: String {
            switch self {
            case .queryPhotosList(let latitude, let longitude):
                return Endpoint.baseUrl + "api_key=" + Auth.flickrKey + "&lat=\(latitude)&lon=\(longitude)&per_page=15&page=\(Int.random(in: 0..<3000))&format=json&nojsoncallback=1"
                
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }
    
    
    class func requestImageFile(url: URL, completion: @escaping (UIImage?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion(nil, error)
                return
            }
            let downloadedImage = UIImage(data: data)
            completion(downloadedImage, nil)
        }
        task.resume()
    }
    
    class func getLocationPhotos(latitude: Double, longitude: Double, completionHandler: @escaping (Photos?, Error?) -> Void) {
        let url = Endpoint.queryPhotosList(latitude, longitude).url
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            debugPrint(String(data: data, encoding: .utf8)!)
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(Photos.self, from: data)
                //debugPrint(response.photos.photo[14])
                DispatchQueue.main.async {
                    completionHandler(response, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                    DispatchQueue.main.async {
                        completionHandler(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                }
            }
        }
        task.resume()
    }
    
    class func photoURL(photo: PhotoURL) -> String {
        let url = "https://live.staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg"
        return url
    }
    
    class func getImage(path: URL, completion: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: path) { data, response, error in
                completion(data, error)
        }
        task.resume()
    }
    
    
}

