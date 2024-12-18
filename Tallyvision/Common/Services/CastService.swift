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
    
    func getCastForShow(withId id: Int64) async throws -> ([Cast], [ShowCast]) {
        var cast = [Cast]()
        var showCast = [ShowCast]()
        let castResponse =  try await httpClinet.fetchCast(forShowId: id)
        
        for individual in castResponse {
            cast.append(individual.cast)
            showCast.append(individual.showCast)
        }
        
        return (cast, showCast)
    }
}
