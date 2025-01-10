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
    var premiereDate: String?
    var endDate: String?
    var network: Network?
    var image: Image?
    var summary: String?

    private enum CodingKeys: String, CodingKey {
        case id, url, number, premiereDate, endDate, network, image, summary
        case episodeCount = "episodeOrder"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int64.self, forKey: .id)
        let urlString = try container.decode(String.self, forKey: .url)
        self.url = URL(string: urlString)!
        
        self.number = try container.decode(Int64.self, forKey: .number)
        self.premiereDate = try container.decodeIfPresent(String.self, forKey: .premiereDate)
        self.endDate = try container.decodeIfPresent(String.self, forKey: .endDate)
        self.network = try container.decodeIfPresent(Network.self, forKey: .network)
        self.image = try container.decodeIfPresent(Image.self, forKey: .image)
        self.summary = try container.decodeIfPresent(String.self, forKey: .summary)
        self.episodeCount = try container.decodeIfPresent(Int64.self, forKey: .episodeCount)
    }
    
}
