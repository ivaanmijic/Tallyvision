//
//  NetworkError.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 5. 11. 2024..
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case message(_ error: Error?)
    case unknown
}
