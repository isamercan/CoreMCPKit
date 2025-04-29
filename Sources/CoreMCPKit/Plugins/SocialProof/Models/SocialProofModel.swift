//
//  SocialProof.swift
//  CoreMCPKit
//
//  Created by İlker İsa Mercan on 28.04.2025.
//

import Foundation
public struct SocialProof: Codable {
    public let reviewCount: Int
    public let averageRating: Double
    public let summary: String
    public let popularityScore: Double
    public let highlightedFeatures: [Feature]?
    public let sentimentBreakdown: SentimentBreakdown
    public let trendingStatus: TrendingStatus?
    public let personalizedSummary: String?
}

public struct Feature: Codable {
    public let name: String
    public let score: Double
}

public struct SentimentBreakdown: Codable {
    public let positive: Double
    public let neutral: Double
    public let negative: Double
}

public enum TrendingStatus: String, Codable {
    case improving = "İyileşiyor"
    case stable = "Sabit"
    case declining = "Geriliyor"
}

public struct UserPreferences {
    public let preferredAmenities: [String]?
    public let budgetRange: (min: Double, max: Double)?
}

// MARK: - Errors
public enum SocialProofError: Error {
    case invalidJSON
    case apiFailure(String)
}


// MARK: - Comment Filter
struct CommentFilter {
    let minRating: Int? // e.g., only comments with 4+ stars
    let dateRange: (start: Date, end: Date)? // e.g., last 30 days
    let keywords: [String]? // e.g., ["havuz", "temizlik"]
    
    static let defaultFilter = CommentFilter(minRating: nil, dateRange: nil, keywords: nil)
}
