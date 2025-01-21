//
//  Season.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 5. 11. 2024..
//

import GRDB

struct Season: Codable, FetchableRecord, PersistableRecord {
    
    static let databaseTableName: String = "seasons"
    
    var id: Int64
    var url: URL
    var number: Int64
    var episodeCount: Int64?

    private enum CodingKeys: String, CodingKey {
        case id, url, number
        case episodeCount = "episodeOrder"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int64.self, forKey: .id)
        let urlString = try container.decode(String.self, forKey: .url)
        self.url = URL(string: urlString)!
        
        self.number = try container.decode(Int64.self, forKey: .number)
        self.episodeCount = try container.decodeIfPresent(Int64.self, forKey: .episodeCount)
    }
    
}
