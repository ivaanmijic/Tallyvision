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
            
            try database.create(table: Show.databaseTableName) { table in
                table.column("id", .integer).primaryKey()
                table.column("name", .text)
                table.column("type", .text)
                table.column("language", .text)
                table.column("status", .text)
                table.column("genres", .text)
                table.column("averageRuntime", .integer)
                table.column("premiered", .date)
                table.column("ended", .date)
                table.column("officialSite", .text)
                table.column("rating", .real)
                table.column("summary", .text)
                table.column("schedule", .text)
                table.column("network", .text)
                table.column("country", .text)
                table.column("image", .text)
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
