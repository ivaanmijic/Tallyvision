//
//  SheduleService.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 28. 11. 2024..
//

import Foundation

class ScheduleService {
    private let httpClient: TVMazeClient
    
    init(httpClient: TVMazeClient) {
        self.httpClient = httpClient
    }
    
    func fetchTodayShows() async throws -> [Show] {
        let episodes = try await httpClient.fetchEpisodes()
        return episodes.map { $0.embeddedShow.show }
    }
}
