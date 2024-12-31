//
//  CastResponse.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 11. 12. 2024..
//

import Foundation

struct CastResponse: Decodable {
    var cast: Person
    var showCast: ShowCast
    
    private enum CodingKeys: String, CodingKey {
        case person, character
    }
    
    private enum PersonKeys: String, CodingKey {
        case id, name, country, birthday, deathday, gender, image
    }
    
    private enum CharacterKeys: String, CodingKey {
        case id, name, image
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let personContainer = try container.nestedContainer(keyedBy: PersonKeys.self, forKey: .person)
        let characterContainer = try container.nestedContainer(keyedBy: CharacterKeys.self, forKey: .character)
       
        cast = Person(
            id: try personContainer.decode(Int64.self, forKey: .id),
            name: try personContainer.decode(String.self, forKey: .name),
            country: try personContainer.decodeIfPresent(Country.self, forKey: .country),
            birthday: try personContainer.decodeIfPresent(String.self, forKey: .birthday),
            deathday: try personContainer.decodeIfPresent(String.self, forKey: .deathday),
            gender: try personContainer.decodeIfPresent(String.self, forKey: .gender),
            image: try personContainer.decodeIfPresent(Image.self, forKey: .image)
        )
        
        showCast = ShowCast(
            showId: 0,
            castId: cast.id,
            characterName: try characterContainer.decode(String.self, forKey: .name)
        )
    }
}
