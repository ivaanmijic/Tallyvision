//
//  ShowTrackerRepository.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 27. 1. 2025..
//

import GRDB

class ShowTrackerRepository {
    private let dbQueue: DatabaseQueue!
    
    init() {
        self.dbQueue = Database.dbQueue
    }
    
    func save(_ tracker: ShowTracker) async throws {
        try await dbQueue.write { db in
            try tracker.save(db)
        }
    }
    
    func fetchShowTracker(for showId: Int64) async throws -> ShowTracker {
        try await dbQueue.read { db in
            guard let tracker = try ShowTracker.fetchOne(db, key: showId) else {
                throw DatabaseError.noTrackerFound
            }
            return tracker
        }
    }
    
    func markEpisodeAsWatched(tracker: ShowTracker, inSeason season: Int64, episode: Int64, runtime: Int64) async throws {
        try await dbQueue.write { db in
            var mutableTracker = tracker
            mutableTracker.markEpisodeAsWatched(inSeason: season, episode: episode, runtime: runtime)
            try mutableTracker.save(db)
        }
    }
    
}
