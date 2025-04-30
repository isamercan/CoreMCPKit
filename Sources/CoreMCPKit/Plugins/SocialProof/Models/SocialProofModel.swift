//
//  SocialProof.swift
//  CoreMCPKit
//
//  Created by İlker İsa Mercan on 28.04.2025.
//

import Foundation

public class SocialProof: NSObject, Codable {
    public let reviewCount: Int?
    public let averageRating: Double?
    public let summary: String?
    public let popularityScore: Double?
    public let highlightedFeatures: [Feature]?
    public let sentimentBreakdown: SentimentBreakdown?
    public let trendingStatus: TrendingStatus?
    public let personalizedSummary: String?
}

public struct Feature: Codable {
    public let name: String?
    public let score: Double?
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

public struct UserPreferences: Codable {
    let preferredAmenities: [String]?
    let budgetRange: BudgetRange?
}

public struct BudgetRange: Codable {
    let min: Double
    let max: Double
}

// MARK: - Errors
public enum SocialProofError: Error {
    case invalidJSON
    case apiFailure(String)
}


// MARK: - Comment Filter
public struct CommentFilter: Sendable {
    public let minRating: Int?
    public let dateRange: (start: Date, end: Date)?
    public let keywords: [String]?
    
    public static let defaultFilter = CommentFilter(minRating: nil, dateRange: nil, keywords: nil)
    
    public init(minRating: Int?, dateRange: (start: Date, end: Date)?, keywords: [String]?) {
        self.minRating = minRating
        self.dateRange = dateRange
        self.keywords = keywords
    }
}

