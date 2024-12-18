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
    
    var id: Int64 = 0
    var showId: Int64
    var castId: Int64
    var characterName: String
    
    private enum CodingKeys: String, CodingKey {
        case id, showId, castId, characterName
    }
    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(Int64.self, forKey: .id)
//        self.showId = try container.decode(Int64.self, forKey: .showId)
//        self.castId = try container.decode(Int64.self, forKey: .castId)
//        self.characterName = try container.decode(String.self, forKey: .characterName)
//    }
}
