//
//  CastCredit.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 31. 12. 2024..
//

import Foundation

struct CastCredit: Decodable {
    var selfCredit: Bool
    var voice: Bool
    private var _embedded: EmbeddedShow
    
    var show: Show {
        return _embedded.show
    }

    private struct EmbeddedShow: Decodable {
        var show: Show
    }
    
    private enum CodingKeys: String, CodingKey {
        case voice, _embedded
        case selfCredit = "self"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.voice = try container.decode(Bool.self, forKey: .voice)
        self._embedded = try container.decode(CastCredit.EmbeddedShow.self, forKey: ._embedded)
        self.selfCredit = try container.decode(Bool.self, forKey: .selfCredit)
    }
}
