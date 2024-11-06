//
//  NetworkError.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 5. 11. 2024..
//

import Foundation

enum NetworkError: Error {
    case decodingError(_ error: DecodingError)
    case encodingErrro(_ error: EncodingError)
    case badResponse(statusCode: Int)
    case requestFailed(_ error: URLError)
    case message(_ error: Error?)
}
