//
//  EpisodeRepository.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 21. 1. 2025..
//

import Foundation
import GRDB

class EpisodeRepository {
    private let dbQueue: DatabaseQueue!
    
    init() {
        self.dbQueue = Database.dbQueue
    }
    
    func create(episode: Episode) async throws {
        try await dbQueue.write { db in
            try episode.insert(db)
        }
    }
    
    func exists(_ episodeId: Int64) async throws -> Bool{
        try await dbQueue.read { db in
            let sql = "SELECT COUNT(*) FROM \(Episode.databaseTableName) WHERE id = ?"
            let count: Int = try Int.fetchOne(db, sql: sql, arguments: [episodeId]) ?? 0
            log.debug("Episode \(episodeId) in database: \(count > 0)")
            return count > 0
        }
    }
    
    func episodesExist(forSeason seasonNumber: Int64, showId: Int64) async throws -> Bool {
        try await dbQueue.read { db in
            let sql = "SELECT COUNT(*) FROM \(Episode.databaseTableName) WHERE season = ? AND showId = ?"
            let count: Int = try Int.fetchOne(db, sql: sql, arguments: [seasonNumber, showId]) ?? 0
            log.info("Episodes in season: \(count)")
            return count > 0
        }
    }
    
    func update(episode: Episode) async throws {
        try await dbQueue.write { db in
            try episode.insert(db, onConflict: .replace)
        }
    }
    
    func update(episodes: [Episode], showId: Int64) async throws {
        guard episodes.count > 0 else { throw DatabaseError.noEpisodesToUpdate }
        
        try await dbQueue.write { db in
            for var episode in episodes {
                episode.hasBeenSeen = true
                episode.showId = showId
                try episode.update(db, onConflict: .replace)
            }
        }
    }
    
    func insert(episodes: [Episode], showId: Int64) async throws {
        try await dbQueue.write { db in
            for var episode in episodes {
                episode.showId = showId
                try episode.insert(db)
            }
        }
    }
    
    func insertOrIgnore(episodes: [Episode], showId: Int64) async throws {
        guard !episodes.isEmpty else { return }
        
        let updatedEpisodes = episodes.map { episode -> Episode in
            var mutableEpisode = episode
            mutableEpisode.showId = showId
            return mutableEpisode
        }
        
        try await dbQueue.write { db in
            for episode in updatedEpisodes {
                try episode.insert(db, onConflict: .ignore)
            }
        }
    }
    
    func fetchAll(forShow showID: Int64) async throws -> [Episode]? {
        try await dbQueue.read { db in
            let sql = "SELECT * FROM \(Episode.databaseTableName) WHERE AND showId = ?"
            return try Episode.fetchAll(db, sql: sql, arguments: [showID])
        }
    }
    
    func fetchEpisodes(forSeason seasonNumber: Int64, show showId: Int64) async throws -> [Episode] {
        try await dbQueue.read { db in
            let table = Episode.databaseTableName
            let query = "SELECT * FROM \(table) WHERE season = ? AND showId = ?"
            return try Episode.fetchAll(db, sql: query, arguments: [seasonNumber, showId])
        }
    }
    
    func fetchEpisode(forSeason season: Int64, number: Int64, showId: Int64) async throws -> Episode? {
        try await dbQueue.read { db in
            let sql = "SELECT * FROM \(Episode.databaseTableName) WHERE showId = ? AND season = ? AND number = ?"
            return try Episode.fetchOne(db, sql: sql, arguments: [showId, season, number])
        }
    }
    
}
