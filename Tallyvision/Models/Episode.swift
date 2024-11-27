//
//  Episode.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 27. 11. 2024..
//

import GRDB

struct Episode: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName: String = "episodes"
    
    var id: Int64
    var url: URL
    var title: String
    var season: Int64
    var number: Int64
    var type: String
    var airDate: String?
    var airTime: String?
    var runtime: Int64?
    var rating: Double?
    var image: Image?
    var summary: String?
    var embeddedShow: EmbeddedShow
    
    struct EmbeddedShow: Codable {
        let show: Show
    }

    private enum CodingKeys: String, CodingKey {
        case id, url, season, number, type, airDate, airTime, runtime, rating, image, summary
        case title = "name"
        case embeddedShow = "_embedded"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int64.self, forKey: .id)
       
        let urlString = try container.decode(String.self, forKey: .url)
        url = URL(string: urlString)!
        
        title = try container.decode(String.self, forKey: .title)
        season = try container.decode(Int64.self, forKey: .season)
        number = try container.decode(Int64.self, forKey: .number)
        type = try container.decode(String.self, forKey: .type)
        
        airDate = try container.decodeIfPresent(String.self, forKey: .airDate)
        airTime = try container.decodeIfPresent(String.self, forKey: .airTime)
        
        runtime = try container.decodeIfPresent(Int64.self, forKey: .runtime)
        
        let ratingContainer = try? container.decode(Rating.self, forKey: .rating)
        if let ratingContainer = ratingContainer {
            self.rating = ratingContainer.average
        } else {
            self.rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        }
        
        image = try container.decodeIfPresent(Image.self, forKey: .image)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        embeddedShow = try container.decode(EmbeddedShow.self, forKey: .embeddedShow)
        
    }
   
}
