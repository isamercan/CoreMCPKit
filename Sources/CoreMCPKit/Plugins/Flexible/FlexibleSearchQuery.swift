//
//  File.swift
//  CoreMCPKit
//
//  Created by isa on 26.04.2025.
//

import Foundation

public struct FlexibleSearchQuery: Codable {
    let location: String
    let type: String?
    let checkInMonth: String?
    let checkInDate: String?
    let checkOutDate: String?
    let adultCount: Int?
    let childCount: Int?
    let childAges: [Int]?
    let url: String?
    let priceConcern: Bool?
}
