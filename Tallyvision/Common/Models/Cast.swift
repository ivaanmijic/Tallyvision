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
    var birthday: String?
    var deathday: String?
    var gender: String?
    var image: Image?
    
    private enum CodingKeys: String, CodingKey {
        case id, name, country, birthday, deathday, gender, image
    }
    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(Int64.self, forKey: .id)
//        self.name = try container.decode(String.self, forKey: .name)
//        self.country = try container.decodeIfPresent(Country.self, forKey: .country)
//        self.birthday = try container.decodeIfPresent(String.self, forKey: .birthday)
//        self.deathday = try container.decodeIfPresent(String.self, forKey: .deathday)
//        self.gender = try container.decodeIfPresent(String.self, forKey: .gender)
//        self.image = try container.decodeIfPresent(Image.self, forKey: .image)
//    }
    
}
