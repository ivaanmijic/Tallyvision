//
//  EpisodeTracker.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 24. 1. 2025..
//

import Foundation

class EpisodeTracker {
    var show: Show
    var seasons: [Season]
    
    private let showRepository = ShowRepository()
    private let episodeRepository = EpisodeRepository()
    private let episodeService = EpisodeService(httpClient: TVMazeClient())
    
    init(show: Show, seasons: [Season]) {
        self.show = show
        self.seasons = seasons
    }
    
    private func ensureShowExists() async throws {
        if !(try await showRepository.exists(showId: show.showId)) {
            try await showRepository.create(show: show)
        }
    }
    
    private func ensureSeasonsExist() async throws {
        log.info(seasons.count)
        for season in self.seasons {
            try await ensureEpisodesExist(for: season)
        }
    }
    
    private func ensureEpisodesExist(for season: Season) async throws {
        let episodes = try await episodeService.fetchEpisodes(forSeason: season.id)
        try await episodeRepository.insert(episodes: episodes, showId: show.showId)
    }
    
    func ensureContentExists() async throws {
        try await ensureShowExists()
        try await ensureSeasonsExist()
    }
    
}
