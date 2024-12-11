//
//  ShowCast.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 11. 12. 2024..
//

import Foundation
import GRDB

struct ShowCast: Codable, FetchableRecord, PersistableRecord {
    
    static let databaseTableName: String = "show_cast"
    
    var id: Int64
    var showId: Int64
    var castId: Int64
    var characterName: String
    
    enum CodingKeys: String, CodingKey {
        case id, showId, castId, characterName
    }
}
