//
//  Cast.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 11. 12. 2024..
//

import GRDB

struct Cast: Codable, FetchableRecord, PersistableRecord {
    
    static let databaseTableName: String = "cast"
    
    var id: Int64
    var name: String
    var country: Country?
    var birtday: String?
    var deathday: String?
    var gender: String?
    var image: Image?
    
}
