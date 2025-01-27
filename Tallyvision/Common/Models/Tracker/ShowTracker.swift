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
    var watchedEpisodeIndices: Set<Int64>
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

    func hasSeenEpisode(at index: Int64) -> Bool {
        return watchedEpisodeIndices.contains(index)
    }

    mutating func markEpisodeAsWatched(at index: Int64, runtime: Int64) {
        watchedEpisodeIndices.insert(index)
        totalTimeSpent += runtime
    }
}
