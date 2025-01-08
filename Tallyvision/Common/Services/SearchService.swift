//
//  SearchService.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 7. 1. 2025..
//

import Foundation

class SearchService {
    private let httpClient: TVMazeClient
    
    init(httpClient: TVMazeClient) {
        self.httpClient = httpClient
    }
    
    func searchShows(forQuery query: String) async throws -> [Show] {
        var shows = [Show]()
        let results = try await httpClient.fetchShows(forQuery: query)
        for result in results {
            shows.append(result.show)
        }
        return shows
    }
}
