//
//  ReviewInsightProviderProtocol.swift
//  CoreMCPKit
//
//  Created by İlker İsa Mercan on 2.05.2025.
//

import Foundation

/// Custom error types for review insight extraction failures.
public enum ReviewInsightExtractionError: Error, LocalizedError {
    case missingResultField
    case invalidDataFormat(String)
    
    public var errorDescription: String? {
        switch self {
            case .missingResultField:
                return "Missing 'result' field in hotel data."
            case .invalidDataFormat(let field):
                return "Invalid format for '\(field)' in hotel data."
        }
    }
}

/// Protocol defining the contract for extracting review insights from hotel data.
public protocol ReviewInsightExtractorProtocol {
    func extractInsights(from hotelData: [String: Any]) throws -> ReviewInsights
}

/// Extracts review insights from hotel data, transforming raw data into structured insights.
public final class HotelReviewInsightExtractor: ReviewInsightExtractorProtocol {
    
    public init() {}
    
    /// Extracts structured review insights from raw hotel data.
    /// - Parameter hotelData: Raw hotel data as a dictionary.
    /// - Returns: A `ReviewInsights` object containing extracted metrics and metadata.
    /// - Throws: `ReviewInsightExtractionError` if data is missing or malformed.
    public func extractInsights(from hotelData: [String: Any]) throws -> ReviewInsights {
        // Ensure the 'result' field exists
        guard let result = hotelData["result"] as? [String: Any] else {
            throw ReviewInsightExtractionError.missingResultField
        }
        
        // Extract hotel code
        let hotelCode = hotelData["hotelCode"] as? String
        
        // Extract average score and review count
        let averageData = result["average"] as? [String: Any]
        let reviewCount = averageData?["reviewCount"] as? Int
        let averageScore = averageData?["score"] as? Double
        
        // Extract overall average score as ReviewCategoryScore
        let overallAverage: ReviewCategoryScore? = {
            if let overallData = averageData?["overall"] as? [String: Any] {
                return ReviewCategoryScore(
                    name: overallData["name"] as? String ?? "Overall",
                    score: overallData["score"] as? Double ?? 0
                )
            }
            return nil
        }()
        
        // Extract category scores (scoreTypes)
        let categoryScores = (result["scoreTypes"] as? [[String: Any]])?.compactMap { scoreData in
            ReviewCategoryScore(
                name: scoreData["name"] as? String ?? "",
                scorecardData["score"] as? Double ?? 0
            )
        } ?? []
        
        // Extract recommendation rate
        let recommendationRate = result["recommendationRate"] as? Double
        
        // Extract price performance score
        let pricePerformanceScore = result["pricePerformance"] as? Double
        
        // Extract flags
        let flags = (result["flags"] as? [[String: Any]])?.compactMap { flagData in
            ReviewInsightFlag(from: flagData) // Assumes ReviewInsightFlag has a failable initializer
        } ?? []
        
        // Extract latest reviews
        let latestReviews = (result["latestReviews"] as? [[String: Any]])?.compactMap { reviewData in
            ReviewSnippet(from: reviewData) // Assumes ReviewSnippet has a failable initializer
        } ?? []
        
        // Construct ReviewInsights
        return ReviewInsights(
            hotelCode: hotelCode,
            averageScore: averageScore,
            totalReviewCount: reviewCount,
            overallAverage: overallAverage,
            categoryScores: categoryScores,
            recommendationRate: recommendationRate,
            pricePerformanceScore: pricePerformanceScore,
            flags: flags,
            latestReviews: latestReviews
        )
    }
}

// Placeholder for ReviewCategoryScore (assuming it exists)
public struct ReviewCategoryScore {
    let name: String
    let score: Double
    
    init(name: String, score: Double) {
        self.name = name
        self.score = score
    }
}

// Placeholder for ReviewInsightFlag (assuming it exists)
public struct ReviewInsightFlag {
    init?(from data: [String: Any]) {
        // Implementation depends on actual structure
        return nil
    }
}

// Placeholder for ReviewSnippet (assuming it exists)
public struct ReviewSnippet {
    init?(from data: [String: Any]) {
        // Implementation depends on actual structure
        return nil
    }
}
