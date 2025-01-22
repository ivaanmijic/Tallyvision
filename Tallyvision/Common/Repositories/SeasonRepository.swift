//
//  SeasonRepository.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 22. 1. 2025..
//

import Foundation
import GRDB

//class SeasonRepository {
//    private let dbQueue: DatabaseQueue!
//    
//    init() {
//        self.dbQueue = Database.dbQueue
//    }
//    
//    func create(_ season: Season) async throws {
//        try await dbQueue.write { db in
//            try season.insert(db)
//        }
//    }
//    
//    func exists(_ seasonId: Int64) async throws -> Bool {
//        try await dbQueue.read { db in
//            let sql = "SELECT COUNT(*) FROM \(Season.databaseTableName) WHERE id = ?"
//            let count: Int = try Int.fetchOne(db, sql: sql, arguments: [seasonId]) ?? 0
//            return count > 0
//        }
//    }
//}
