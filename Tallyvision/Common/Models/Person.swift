//
//  Cast.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 11. 12. 2024..
//

import GRDB

struct Person: Codable, FetchableRecord, PersistableRecord {
    
    static let databaseTableName: String = "person"
    
    var id: Int64
    var name: String
    var country: Country?
    var birthday: String?
    var deathday: String?
    var gender: String?
    var image: Image?
    
    private enum CodingKeys: String, CodingKey {
        case id, name, country, birthday, deathday, gender, image
    }
    
    
}
