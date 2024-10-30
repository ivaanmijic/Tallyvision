//
//  TVShow.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 29. 10. 2024..
//

import GRDB

struct Show: Codable, FetchableRecord, PersistableRecord {
   
    static let databaseTableName = "tv_shows"
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    var showId: Int64
    var title: String
    var type: String
    var language: String
    var genres: [String]
    var status: String
    var averageRuntime: Int64
    var premiereDate: Date?
    var endDate: Date?
    var officialSite: String?
    var schedule: Schedule
    var rating: Double?
    var network: Network?
    var image: Image
    var summary: String
   
    private struct Rating: Codable {
        let average: Double?
    }
    
    struct Schedule: Codable {
        let time: String
        let days: [String]
    }
    
    struct Network: Codable {
        let id: Int
        let name: String
        let country: Country
        let officialSite: String?
    }
    
    struct Country: Codable {
        let name: String
        let code: String
        let timezone: String
    }
   
    struct Image: Codable {
        let medium: String?
        let original: String?
    }
    
    private enum CodingKeys: String, CodingKey {
        case type, language, rating, summary, officialSite, genres, status, averageRuntime, schedule, network, image
        case showId = "id"
        case title = "name"
        case premiereDate = "premiered"
        case endDate = "ended"
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.showId = try container.decode(Int64.self, forKey: .showId)
        self.title = try container.decode(String.self, forKey: .title)
        self.type = try container.decode(String.self, forKey: .type)
        self.language = try container.decode(String.self, forKey: .language)
        self.genres = try container.decode([String].self, forKey: .genres)
        self.status = try container.decode(String.self, forKey: .status)
        self.averageRuntime = try container.decode(Int64.self, forKey: .averageRuntime)
        
        
//        if let premiereDateString = try container.decodeIfPresent(String.self, forKey: .premiereDate) {
//            print(premiereDateString)
//            self.premiereDate = Self.dateFormatter.date(from: premiereDateString)
//            print(premiereDate)
//        }
//        
//        if let endDateString = try container.decodeIfPresent(String.self, forKey: .endDate) {
//            self.endDate = Self.dateFormatter.date(from: endDateString)
//        }
//        self.premiereDate = try container.decodeIfPresent(String.self, forKey: .premiereDate)
//        self.endDate = try container.decodeIfPresent(String.self, forKey: .endDate)

        if let premiereDateString = try container.decodeIfPresent(String.self, forKey: .premiereDate) {
            print("Decoded premiere date string: \(premiereDateString)")
            self.premiereDate = Self.dateFormatter.date(from: premiereDateString)
        } else {
            self.premiereDate = nil
        }

        if let endDateString = try container.decodeIfPresent(String.self, forKey: .endDate) {
            print("Decoded end date string: \(endDateString)")
            self.endDate = Self.dateFormatter.date(from: endDateString)
        } else {
            self.endDate = nil
        }

       
        self.officialSite = try container.decodeIfPresent(String.self, forKey: .officialSite)
        self.schedule = try container.decode(Schedule.self, forKey: .schedule)
        
        let ratingContainer = try? container.decode(Rating.self, forKey: .rating)
        if let ratingContainer = ratingContainer {
            self.rating = ratingContainer.average
        } else {
            self.rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        }
        
        self.network = try container.decodeIfPresent(Network.self, forKey: .network)
        self.image = try container.decode(Image.self, forKey: .image)
        self.summary = try container.decode(String.self, forKey: .summary)
      
    }
}
