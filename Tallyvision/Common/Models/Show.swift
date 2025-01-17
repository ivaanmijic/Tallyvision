//
//  TVShow.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 29. 10. 2024..
//

import GRDB

struct Show: Codable, FetchableRecord, PersistableRecord {
   
    static let databaseTableName = "tv_shows"
    
    var showId: Int64
    var url: URL
    var title: String
    var type: String
    var language: String?
    var genres: [String]
    var status: String
    var averageRuntime: Int64?
    var premiereDate: String?
    var endDate: String?
    var officialSite: String?
    var schedule: Schedule
    var rating: Double?
    var network: Network?
    var image: Image?
    var summary: String?
    
    var isListed = false
   
    
    struct Schedule: Codable {
        let time: String
        let days: [String]
    }
    
    
    private enum CodingKeys: String, CodingKey {
        case type, language, rating, summary, officialSite, genres, status, averageRuntime, schedule, network, image, url
        case showId = "id"
        case title = "name"
        case premiereDate = "premiered"
        case endDate = "ended"
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.showId = try container.decode(Int64.self, forKey: .showId)
        
        let urlString = try container.decode(String.self, forKey: .url)
        self.url = URL(string: urlString)!
        
        self.title = try container.decode(String.self, forKey: .title)
        self.type = try container.decode(String.self, forKey: .type)
        self.language = try container.decodeIfPresent(String.self, forKey: .language)
        self.genres = try container.decode([String].self, forKey: .genres)
        self.status = try container.decode(String.self, forKey: .status)
        self.averageRuntime = try container.decodeIfPresent(Int64.self, forKey: .averageRuntime)
        self.premiereDate = try container.decodeIfPresent(String.self, forKey: .premiereDate)
        self.endDate = try container.decodeIfPresent(String.self, forKey: .endDate)
        self.officialSite = try container.decodeIfPresent(String.self, forKey: .officialSite)
        self.schedule = try container.decode(Schedule.self, forKey: .schedule)
       
        
        let ratingContainer = try? container.decode(Rating.self, forKey: .rating)
        if let ratingContainer = ratingContainer {
            self.rating = ratingContainer.average
        } else {
            self.rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        }
        
        self.network = try container.decodeIfPresent(Network.self, forKey: .network)
        self.image = try container.decodeIfPresent(Image.self, forKey: .image)
        self.summary = try container.decodeIfPresent(String.self, forKey: .summary)
      
    }
}


// MARK: - implementing Hashable

extension Show: Hashable {
    static func == (lhs: Show, rhs: Show) -> Bool {
        return lhs.showId == rhs.showId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(showId)
    }
}



