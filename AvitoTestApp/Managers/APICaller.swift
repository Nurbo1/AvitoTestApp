//
//  APICaller.swift
//  AvitoTestApp
//
//  Created by Нурбол Мухаметжан on 11.09.2024.
//

import Foundation

struct Constants {
    static let API_KEY = api_key // write here your own api_key
    static let BASE_URL = "https://api.unsplash.com"
}

enum APIError: Error {
    case failedToGetData
    case rateLimitExceeded
    case invalidURL
}

class APICaller {
    
    static let shared = APICaller()
    
    var searchResultTitles: [String: [Image]] = [:]
    
    func search(with query: String, completion: @escaping (Result<[Image], Error>) -> Void) {
        
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        if let cachedImages = searchResultTitles[encodedQuery] {
            print("From cache")
            completion(.success(cachedImages))
            return
        }
        
        guard let url = URL(string: "\(Constants.BASE_URL)/search/photos?query=\(encodedQuery)&per_page=30&client_id=\(Constants.API_KEY)") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 429 {
                print("DEBUG: Rate limit exceeded")
                completion(.failure(APIError.rateLimitExceeded))
                return
            }
            
            guard let data = data, error == nil else {
                print("DEBUG: Problem in fetching data, error: \(String(describing: error))")
                completion(.failure(error ?? APIError.failedToGetData))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(Images.self, from: data)
                self.searchResultTitles[encodedQuery] = decodedData.results
                completion(.success(decodedData.results))
            } catch {
                print("DEBUG: Error decoding data: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
