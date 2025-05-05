//
//  ReviewCategoryScore.swift
//  CoreMCPKit
//
//  Created by İlker İsa Mercan on 2.05.2025.
//

import Foundation

public struct ReviewCategoryScore: Codable, Identifiable, Hashable {
    public var id = UUID()
    public let name: String?
    public let score: Double?
    
    public init(name: String, score: Double) {
        self.name = name
        self.score = score
    }
}
