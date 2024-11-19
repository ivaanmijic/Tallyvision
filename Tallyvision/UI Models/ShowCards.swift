//
//  ShowCard.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 12. 11. 2024..
//

import Foundation

class ShowCards {
    
    private var shows: [Show]
    private var currentShowIndex: Int = 0
        
    init(shows: [Show]) {
        self.shows = shows
    }
    
    func currentShow() -> Show? {
        guard shows.indices.contains(currentShowIndex) else { return nil }
        return shows[currentShowIndex]
    }
    
    func goToNextShow() {
        currentShowIndex = (currentShowIndex < shows.count - 1) ? currentShowIndex + 1 : 0
    }
    
    func goToPrevShow() {
        currentShowIndex = (currentShowIndex > 0) ? currentShowIndex - 1 : shows.count - 1
    }
    
    func addShow(_ show: Show) {
        shows.append(show)
    }
    
}
