//
//  Database+Migrator.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 27. 11. 2024..
//

import GRDB

extension Database {
    
    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("createShows") { db in
            try db.create(table: Show.databaseTableName) { t in
                t.column("id", .integer).primaryKey()
                t.column("url", .text).notNull()
                t.column("name", .text).notNull()
                t.column("type", .text).notNull()
                t.column("language", .text)
                t.column("status", .text).notNull()
                t.column("genres", .text).notNull()
                t.column("averageRuntime", .integer)
                t.column("premiered", .text).notNull()
                t.column("ended", .text)
                t.column("officialSite", .text)
                t.column("rating", .real)
                t.column("summary", .text)
                t.column("schedule", .jsonText).notNull()
                t.column("network", .jsonText)
                t.column("country", .jsonText)
                t.column("image", .text)
                t.column("isListed", .boolean).notNull()
            }
        }
        
        migrator.registerMigration("createEpisodes") { db in
            try db.create(table: Episode.databaseTableName) { t in
                t.column("id", .integer).primaryKey()
                t.column("url", .text).notNull()
                t.column("showId", .integer).notNull().references(Show.databaseTableName, onDelete: .cascade)
                t.column("season", .integer).notNull()
                t.column("number", .integer)
                t.column("type", .text)
                t.column("airDate", .text)
                t.column("airTime", .text)
                t.column("runtime", .integer)
                t.column("rating", .real)
                t.column("image", .text)
                t.column("summary", .text)
                t.column("hasBeenSeen", .boolean).notNull()
                t.column("name", .text).notNull()
            }
        }
        
        migrator.registerMigration("createCast") { db in
            try db.create(table: Person.databaseTableName) { t in
                t.column("id", .integer).primaryKey()
                t.column("name", .text).notNull()
                t.column("country", .jsonText)
                t.column("birthday", .text)
                t.column("deathday", .text)
                t.column("gender", .text)
                t.column("image", .text)
            }
        }
        
        migrator.registerMigration("createShowCast") { db in
            try db.create(table: ShowCast.databaseTableName) { t in
                t.column("id", .integer).primaryKey(autoincrement: true)
                t.column("showId", .integer).notNull().references(Show.databaseTableName, onDelete: .cascade)
                t.column("castId", .integer).notNull().references(Person.databaseTableName, onDelete: .cascade)
            }
        }
        
        
#if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
#endif
        
        return migrator
    }
    
}
