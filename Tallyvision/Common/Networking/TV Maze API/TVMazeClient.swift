//
//  TVMazeClient.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 5. 11. 2024..
//


import Foundation

class TVMazeClient {
    
    let baseURL = "https://api.tvmaze.com/"
    static let dateFormatter: DateFormatter = .apiDateFormatter
    
    func fetchShows() async throws -> [Show] {
        let url = URL(string: "\(baseURL)shows")!
        return try await fetchData(from: url)
    }
    
    func fetchShow(byId id: Int) async throws -> Show {
        let url = URL(string: "\(baseURL)shows/\(id)")!
        return try await fetchData(from: url)
    }
    
    func fetchEpisodes(forDate date: Date) async throws -> [Episode] {
        let dateString = Self.dateFormatter.string(from: date)
        let url = URL(string: "https://api.tvmaze.com/schedule?date=\(dateString)&country=US")!
        return try await fetchData(from: url)
    }
    
    func fetchWebEpisodes(forDate date: Date) async throws -> [Episode] {
        let dateString = Self.dateFormatter.string(from: date)
        let url = URL(string: "https://api.tvmaze.com/schedule/web?date=\(dateString)&country=US")!
        return try await fetchData(from: url)
    }
    
    func fetchCast(forShowId showId: Int64) async throws -> [CastResponse] {
        let url = URL(string: "\(baseURL)shows/\(showId)/cast")!
        return try await fetchData(from: url)
    }
    
    func fetchCredits(forCastId castId: Int64) async throws -> [CastCredit] {
        let url = URL(string: "\(baseURL)people/\(castId)/castcredits?embed=show")!
        return try await fetchData(from: url)
    }
    
    func fetchSeason(forShowId showId: Int64) async throws -> [Season] {
        let url = URL(string: "\(baseURL)shows/\(showId)/seasons")!
        return try await fetchData(from: url)
    }
    
    func fetchShows(forQuery query: String) async throws -> [SearchResponse] {
        let url = URL(string: "\(baseURL)search/shows?q=\(query)")!
        return try await fetchData(from: url)
    }
   
    private func fetchData<Data: Decodable>(from url: URL) async throws -> Data {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response as? HTTPURLResponse, 200 ... 299 ~= response.statusCode else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                throw NetworkError.badResponse(statusCode: statusCode)
            }
            let decodedData = try JSONDecoder().decode(Data.self, from: data)
            log.info("Decoded data type: \(type(of: decodedData))")
            return decodedData
        } catch let decodingError as DecodingError {
            throw NetworkError.decodingError(decodingError)
        } catch {
            throw NetworkError.message(error)
        }
    }
}
