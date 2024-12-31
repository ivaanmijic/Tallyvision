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
       
        let shows = todayEpisodes.compactMap { $0.show }
            .filter {$0.type != "News" && $0.rating ?? 0.0 > 6.5 }
            .filter { $0.image?.original != nil }
           
        return Array(Set(shows))
    }
    
    func getRecentShows() async throws -> [Show] {
        let shows = try await fetchShows(daysToFetch: daysToFetch, relativeTo: -1)
            .filter { $0.image?.medium != nil }
        
        return Array(Set(shows))
    }
    
    func getUpcomingShows() async throws -> [Show] {
        let shows = try await fetchShows(daysToFetch: daysToFetch, relativeTo: 1)
            .filter { $0.image?.medium != nil }
        
        return Array(Set(shows))
    }
    
    private func fetchShows(daysToFetch: Int, relativeTo direction: Int) async throws -> [Show] {
        let dates = (1...daysToFetch).map {
            DateFormatter.apiDateFormatter.string(from: currentDate + Double($0 * direction) * Date.dayInterval)
        }
        
        let episodes = try await fetchEpisodes(forDaysToFetch: daysToFetch, startingFrom: direction)
        
        return episodes.compactMap { $0.show }
            .filter { dates.contains($0.premiereDate) }
        
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
