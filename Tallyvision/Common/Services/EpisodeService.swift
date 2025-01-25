//
//  EpisodeService.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 13. 1. 2025..
//

import Foundation

class EpisodeService {
    private let httpClient: TVMazeClient
    
    init(httpClient: TVMazeClient) {
        self.httpClient = httpClient
    }
    
    func fetchEpisodes(forSeason seasonId: Int64) async throws -> [Episode] {
        return try await httpClient.fetchEpisodes(forSeasonId: seasonId)
    }
    
    func getEpisodes(forShow showId: Int64) async throws -> [Episode] {
        return try await httpClient.fetchEpisodes(forShowId: showId)
    }

}
