//
//  Database.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 29. 10. 2024..
//

import GRDB

struct Database {
    
    static var dbQueue: DatabaseQueue!
    
    static func setupDatabase(for application: UIApplication) throws {
        let databaseURL = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("db.sqlite")
       
        log.info(databaseURL.path)
        dbQueue = try! Self.openDatabase(atPath: databaseURL.path)
    }
    
    static func openDatabase(atPath path: String) throws -> DatabaseQueue {
        dbQueue = try DatabaseQueue(path: path)
        try migrator.migrate(dbQueue)
        
        return dbQueue
    }
    
}
