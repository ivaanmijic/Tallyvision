//
//  ShowRepository.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 17. 1. 2025..
//

import GRDB

class ShowRepository {
    private let dbQueue: DatabaseQueue!
    
    init() {
        self.dbQueue = Database.dbQueue
    }
    
    func create(show: Show) async throws {
        try await dbQueue.write { db in
            try show.insert(db)
        }
    }
    
    func exists(showId: Int64) async throws -> Bool {
        try await dbQueue.read { db in
            let sql = "SELECT COUNT(*) FROM \(Show.databaseTableName) WHERE id = ?"
            let count: Int = try Int.fetchOne(db, sql: sql, arguments: [showId]) ?? 0
            return count > 0
        }
    }
    
    func fetchStatus(forID id: Int64) async throws -> Bool? {
        try await dbQueue.read { db in
            let shows = Show.databaseTableName
            let status = try Bool.fetchOne(db, sql: "SELECT isListed FROM \(shows) WHERE id = ?", arguments: [id])
            return status
        }
    }
    
    func remove(show: Show) async throws -> Bool? {
        try await dbQueue.write { db in
            try show.delete(db)
        }
    }
    
    func fetchListedShows() async throws -> [Show] {
        try await dbQueue.read { db in
            let shows = Show.databaseTableName
            let query = "SELECT * FROM \(shows) WHERE isListed = True"
            return try Show.fetchAll(db, sql: query)
        }
    }
    
}
