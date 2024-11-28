//
//  Network.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 5. 11. 2024..
//

import Foundation

struct Network: Codable {
    let id: Int
    let name: String
    let country: Country
    let officialSite: String?
}
