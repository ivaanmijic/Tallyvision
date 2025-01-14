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
    
    func fetchEpisodesForSeason(withId id: Int64) async throws -> [Episode] {
        let episodes =  try await httpClient.fetchEpisodes(forSeasonId: id)
        log.debug(episodes.count)
        return episodes
    }

}
