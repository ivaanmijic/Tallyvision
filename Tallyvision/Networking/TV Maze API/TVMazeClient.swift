//
//  TVMazeClient.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 5. 11. 2024..
//

import Foundation

class TVMazeClient {
    static let shared = TVMazeClient()
    private init() {}
    private let baseURL = "https://api.tvmaze.com/"
    
    func fetchShows(completion: @escaping (Result<[Show], NetworkError>) -> Void) {
        guard let url = URL(string: "\(baseURL)shows") else {
            completion(.failure(.invalidURL))
            return
        }
        fetchData(from: url, completion: completion)
    }
    
    func fetchShow(byId id: Int, completion: @escaping (Result<Show, NetworkError>) -> Void) {
        guard let url = URL(string: "\(baseURL)shows/\(id)") else {
            completion(.failure(.invalidURL))
            return
        }
        fetchData(from: url, completion: completion)
    }
   
    private func fetchData<Data: Decodable>(from url: URL, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(.failure(.unknown))
                return
            }
            
            guard let response = response as? HTTPURLResponse, 200 ... 299 ~= response.statusCode else {
                completion(.failure(.unknown))
                return
            }
            
            do {
                let data = try JSONDecoder().decode(Data.self, from: data)
                completion(.success(data))
            } catch {
                completion(.failure(.message(error)))
            }
        }.resume()
    }
    
}
