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
    
    func fetchAll() async throws -> [ShowTracker] {
        try await dbQueue.read { db in
            try ShowTracker.fetchAll(db)
        }
    }
    
    func fetchAll(withStatus status: Status) async throws -> [ShowTracker] {
        try await dbQueue.read { db in
            let sql = "SELECT * FROM \(ShowTracker.databaseTableName) WHERE status = ?"
            return try ShowTracker.fetchAll(db, sql: sql, arguments: [status.rawValue])
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
    
}
