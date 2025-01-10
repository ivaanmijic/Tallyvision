//
//  SeasonService.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 8. 1. 2025..
//

import Foundation

class SeasonService {
    private let httpClient: TVMazeClient
    
    init(httpClient: TVMazeClient) {
        self.httpClient = httpClient
    }
    
    func getSeasonsFowShow(withId showId: Int64) async throws -> [Season] {
        let seasons = try await httpClient.fetchSeason(forShowId: showId)
        log.debug("service: \(seasons.count)")
        return seasons
    }
}
