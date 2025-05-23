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
    var number: Int64?
    var type: String
    var airdate: String?
    var airtime: String?
    var runtime: Int64?
    var rating: Double?
    var image: Image?
    var summary: String?
    var hasBeenSeen: Bool
    
    var _embeddedShow: EmbeddedShow?
    var _show: Show?
    
    var show: Show? {
        guard let show = _show else { return  _embeddedShow?.show }
        return show
    }
    
    var showId: Int64?
    
    struct EmbeddedShow: Codable {
        let show: Show
    }

    private enum CodingKeys: String, CodingKey {
        case id, url, season, number, type, airdate, airtime, runtime, rating, image, summary, hasBeenSeen
        case title = "name"
        case _show = "show"
        case _embeddedShow = "_embedded"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        let urlString = try container.decode(String.self, forKey: .url)
        url = URL(string: urlString)!
        title = try container.decode(String.self, forKey: .title)
        season = try container.decode(Int64.self, forKey: .season)
        number = try container.decodeIfPresent(Int64.self, forKey: .number)
        type = try container.decode(String.self, forKey: .type)
        airdate = try container.decodeIfPresent(String.self, forKey: .airdate)
        airtime = try container.decodeIfPresent(String.self, forKey: .airtime)
        runtime = try container.decodeIfPresent(Int64.self, forKey: .runtime)
        image = try container.decodeIfPresent(Image.self, forKey: .image)
        summary = try container.decodeIfPresent(String.self, forKey: .summary)
        hasBeenSeen = try container.decodeIfPresent(Bool.self, forKey: .hasBeenSeen) ?? false
        _embeddedShow = try container.decodeIfPresent(EmbeddedShow.self, forKey: ._embeddedShow)
        _show = try container.decodeIfPresent(Show.self, forKey: ._show)
        
        let ratingContainer = try? container.decode(Rating.self, forKey: .rating)
        
        if let ratingContainer = ratingContainer {
            self.rating = ratingContainer.average
        } else {
            self.rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        }
    }
    
    func encode(to container: inout PersistenceContainer) throws {
        container["id"] = id
        container["url"] = url
        container["showId"] = showId
        container["season"] = season
        container["number"] = number
        container["type"] = type
        container["airdate"] = airdate
        container["airtime"] = airtime
        container["runtime"] = runtime
        container["rating"] = rating
        container["image"] = image
        container["summary"] = summary
        container["hasBeenSeen"] = hasBeenSeen
        container["name"] = title
    }
  
    mutating func setShowId(_ id: Int64) {
        showId = id
    }
    
}

extension Episode: Equatable {
    static func ==(lhs: Episode, rhs: Episode) -> Bool {
        return lhs.id == rhs.id
    }
}

