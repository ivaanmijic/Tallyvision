//
//  ShowTracker.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 27. 1. 2025..
//

import Foundation
import GRDB

struct ShowTracker: Codable, FetchableRecord, PersistableRecord {
    let showID: Int64
    var watchedEpisodes: Set<EpisodeTracker>
    var totalTimeSpent: Int64
    var status: Status
    var isWatchlisted: Bool

    static var databaseTableName: String = "showTracker"
    
    mutating func addToWatchlist() {
        isWatchlisted = true
    }

    mutating func removeFromWatchlist() {
        isWatchlisted = false
    }

    func hasSeenEpisode(inSeason season: Int64, episode: Int64) -> Bool {
        let episodeTracker = EpisodeTracker(season: season, episode: episode)
        return watchedEpisodes.contains(episodeTracker)
    }

    mutating func markEpisodeAsWatched(inSeason season: Int64, episode: Int64, runtime: Int64) {
        let episodeTracker = EpisodeTracker(season: season, episode: episode)
        watchedEpisodes.insert(episodeTracker)
        totalTimeSpent += runtime
    }
}
