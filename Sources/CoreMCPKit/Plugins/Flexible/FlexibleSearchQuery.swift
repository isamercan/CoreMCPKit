//
//  File.swift
//  CoreMCPKit
//
//  Created by isa on 26.04.2025.
//

import Foundation
public struct FlexibleSearchQuery: Codable {
    public let location: String
    public let type: String?
    public let checkInMonth: String?
    public let priceConcern: Bool?
}
