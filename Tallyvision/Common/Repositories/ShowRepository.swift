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
    
    func create(show: Show) throws {
        try dbQueue.write { db in
            try show.insert(db)
        }
    }
    
    func fetchStatus(forID id: Int64) throws -> Bool? {
        try dbQueue.read { db in
            let shows = Show.databaseTableName
            let status = try Bool.fetchOne(db, sql: "SELECT isListed FROM \(shows) WHERE id = ?", arguments: [id])
            return status
        }
    }
    
    func remove(show: Show) throws -> Bool? {
        try dbQueue.write { db in
            try show.delete(db)
        }
    }
    
}
