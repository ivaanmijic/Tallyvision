//
//  SheduleService.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 28. 11. 2024..
//

import Foundation

class ScheduleService {
    private let currentDate = Date()
    private let daysToFetch = 10
    
    private let httpClient: TVMazeClient
    
    init(httpClient: TVMazeClient) {
        self.httpClient = httpClient
    }
    
    func getTodaysShows() async throws -> [Show] {
        let todayEpisodes = try await fetchEpisodes(forDate: currentDate)
        var seenShowIds = Set<Int64>()
       
        return todayEpisodes.compactMap { $0.show }
            .filter {$0.type != "News" && $0.rating ?? 0.0 > 7.0 }
            .filter { show in
                if seenShowIds.contains(show.showId) {
                    return false
                }
                else {
                    seenShowIds.insert(show.showId)
                    return true
                }
            }
    }
    
    func getRecentShows() async throws -> [Show] {
        return try await fetchShows(daysToFetch: daysToFetch, relativeTo: -1)
    }
    
    func getUpcomingShows() async throws -> [Show] {
        return try await fetchShows(daysToFetch: daysToFetch, relativeTo: 1)
    }
    
    private func fetchShows(daysToFetch: Int, relativeTo direction: Int) async throws -> [Show] {
        var shows = [Show]()
        let dates = (1...daysToFetch).map {
            DateFormatter.apiDateFormatter.string(from: currentDate + Double($0 * direction) * Date.dayInterval)
        }
        
        let episodes = try await fetchEpisodes(forDaysToFetch: daysToFetch, startingFrom: direction)
        
        for episode in episodes {
            
            guard let show = episode.show,
                  dates.contains(show.premiereDate),
                  !shows.contains(where: { $0.showId == show.showId })
            else { continue }
            
            shows.append(show)
        }
        
        return shows
    }
    
    private func fetchEpisodes(forDaysToFetch daysToFetch: Int, startingFrom offset: Int) async throws -> [Episode] {
        let dates = (1...daysToFetch).map { currentDate + Double($0 * offset) * Date.dayInterval }
       
        return try await withThrowingTaskGroup(of: [Episode].self) { group in
            for date in dates {
                group.addTask { [self] in
                    return try await fetchEpisodes(forDate: date)
                }
            }
            
            return try await group.reduce(into: []) { $0 += $1 }
        }
        
    }
    
    private func fetchEpisodes(forDate date: Date) async throws -> [Episode] {
        
        return try await withThrowingTaskGroup(of: [Episode].self) { group in
            group.addTask { [self] in
                return try await httpClient.fetchEpisodes(forDate: date)
            }
            
            group.addTask { [self] in
                return try await httpClient.fetchWebEpisodes(forDate: date)
            }
            
            return try await group.reduce(into: []) { $0 += $1 }
        }
    }
}
