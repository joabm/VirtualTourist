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
        static let secretKey = "490a82223e18ce1c"
        
    }
        
    enum Endpoint {
        
        case queryPhotosList(Double, Double)
        static let baseUrl = "https://www.flickr.com/services/rest/?method=flickr.photos.search&"
                
        var stringValue: String {
            switch self {
            case .queryPhotosList(let latitude, let longitude):
                return Endpoint.baseUrl + "api_key=" + Auth.flickrKey + "&lat=\(latitude)&lon=\(longitude)&per_page=30&page=\(Int.random(in: 0..<4000))&format=json&nojsoncallback=1"
                
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }
    
    func test(){
        print(Endpoint.queryPhotosList(3.0, 4.0).url)
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

    class func getLocationPhotos(latitude: Double, longitude: Double, completion: @ escaping ([Photos], Error?) -> Void ) {
        taskForGETRequest(url: Endpoint.queryPhotosList(latitude, longitude).url, response: FlickrResponse.self) { response, error in
            //debugPrint(Endpoint.queryPhotosList(latitude, longitude).url)
            if let response = response {
                print(response.photos.photo)
                completion(response.photos.photo, nil)
            } else {
                completion([], error)
            }
        }
    }
    
    @discardableResult class func taskForGETRequest<ResponseType: Decodable>(url: URL, response: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            debugPrint(String(data: data, encoding: .utf8)!)
            let decoder = JSONDecoder()

            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                print(responseObject)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
        task.resume()
        return task
    }
    
    
}

