//
//  Image.swift
//  Tallyvision
//
//  Created by Ivan Mijic on 5. 11. 2024..
//

import Foundation
import GRDB

struct Image: Codable, DatabaseValueConvertible {
    let medium: String?
    let original: String?
}
