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

// Migrator
extension Database {
    
    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("createShows") { database in
           
            if try database.tableExists(Show.databaseTableName) {
                try database.drop(table: Show.databaseTableName)
            }
            
            try database.create(table: Show.databaseTableName) { t in
                t.column("id", .integer).primaryKey()
                t.column("url", .text)
                t.column("name", .text)
                t.column("type", .text)
                t.column("language", .text)
                t.column("status", .text)
                t.column("genres", .text)
                t.column("averageRuntime", .integer)
                t.column("premiered", .date)
                t.column("ended", .date)
                t.column("officialSite", .text)
                t.column("rating", .real)
                t.column("summary", .text)
                t.column("schedule", .jsonText)
                t.column("network", .jsonText)
                t.column("country", .jsonText)
                t.column("image", .text)
            }
            
            try database.create(table: Season.databaseTableName) { t in
                t.column("id", .integer).primaryKey()
                t.column("showId", .integer).references(Show.databaseTableName, onDelete: .cascade)
                t.column("number", .integer)
                t.column("episodeOrder", .integer)
                t.column("premiereDate", .date)
                t.column("endDate", .date)
                t.column("network", .jsonText)
                t.column("image", .text)
                t.column("summary", .text)
            }
        }
        
        #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        return migrator
    }
    
    
    // MARK: - Test
    func insertShow(_ show: Show) {
        try? Self.dbQueue?.write { db in
                try show.insert(db)
            }
        }
    
    func fetchShows() -> [Show]? {
        return try? Self.dbQueue.read { db in
            try Show.fetchAll(db)
        }
    }
    
}
