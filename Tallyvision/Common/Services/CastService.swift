//
//  CastService.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 16. 12. 2024..
//

import Foundation

class CastService {
    private let httpClinet: TVMazeClient
    
    init(httpClinet: TVMazeClient) {
        self.httpClinet = httpClinet
    }
    
    func getCastForShow(withId id: Int64) async throws -> [CastResponse] {
        return try await httpClinet.fetchCast(forShowId: id)
    }
}
