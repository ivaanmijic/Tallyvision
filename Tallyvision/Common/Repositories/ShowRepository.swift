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
    
    func fetchAll(withIDs ids: [Int64]) async throws -> [Show] {
        try await dbQueue.read {db in
            return try Show.fetchAll(db, keys: ids)
        }
    }
    
    func create(show: Show) async throws {
        try await dbQueue.write { db in
            try show.insert(db, onConflict: .replace)
        }
    }
    
    func insertOrIgnore(show: Show) async throws {
        try await dbQueue.write { db in
            try show.insert(db, onConflict: .ignore)
        }
    }
    
    func remove(show: Show) async throws -> Bool? {
        try await dbQueue.write { db in
            try show.delete(db)
        }
    }
    
}
