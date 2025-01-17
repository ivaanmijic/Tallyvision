//
//  ShowRepository.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 17. 1. 2025..
//

import GRDB

class ShowRepository {
    private let dbQueue: DatabaseQueue!
    
    init() {
        self.dbQueue = Database.dbQueue
    }
    
    func create(show: Show) throws {
        try dbQueue.write { db in
            try show.insert(db)
        }
    }
    
}
