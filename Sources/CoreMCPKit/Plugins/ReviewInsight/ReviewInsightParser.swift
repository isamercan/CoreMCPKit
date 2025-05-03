//
//  ReviewInsightParser.swift
//  CoreMCPKit
//
//  Created by İlker İsa Mercan on 2.05.2025.
//
import Foundation

/// Custom error types for review insight parsing failures.
public enum ReviewInsightParseError: Error, LocalizedError {
    case missingField(String)
    case invalidDataFormat(String)
    
    public var errorDescription: String? {
        switch self {
            case .missingField(let field):
                return "Missing '\(field)' field in JSON data."
            case .invalidDataFormat(let field):
                return "Invalid format for '\(field)' in JSON data."
        }
    }
}

/// Protocol defining the contract for parsing review insights from JSON data.
public protocol ReviewInsightParserProtocol {
    func parse(from json: [String: Any], hotelCode: String) throws -> ReviewInsights
}

/// Parses review insights from JSON data, transforming raw data into structured insights for a specific hotel.
public struct HotelReviewInsightParser: ReviewInsightParserProtocol {
    
    public init() {}
    
    /// Parses structured review insights from raw JSON data for a given hotel.
    /// - Parameters:
    ///   - json: Raw JSON data as a dictionary.
    ///   - hotelCode: Unique identifier for the hotel.
    /// - Returns: A `ReviewInsights` object containing extracted metrics and metadata.
    /// - Throws: `ReviewInsightParseError` if data is missing or malformed.
    public func parse(from json: [String: Any], hotelCode: String) throws -> ReviewInsights {
        // Extract average data
        guard let average = json["average"] as? [String: Any] else {
            throw ReviewInsightParseError.missingField("average")
        }
        
        // Extract average score and total review count
        let averageScore = average["score"] as? Double
        let totalReviewCount = average["reviewCount"] as? Int
        
        // Extract overall average score as ReviewCategoryScore
        let overallAverage: ReviewCategoryScore? = {
            if let overallData = average["overall"] as? [String: Any],
               let name = overallData["name"] as? String,
               let score = overallData["score"] as? Double {
                return ReviewCategoryScore(name: name, score: score)
            }
            return nil
        }()
        
        // Extract category scores from scoreTypes
        let scoreTypes = (json["scoreTypes"] as? [[String: Any]])?.compactMap { dict in
            guard let name = dict["name"] as? String,
                  let score = dict["score"] as? Double else {
                return nil
            }
            return ReviewCategoryScore(name: name, score: score)
        } ?? []
        
        // Extract additional category scores from scoreAverages
        let scoreAverages = (json["scoreAverages"] as? [[String: Any]])?.compactMap { dict in
            guard let name = dict["name"] as? String,
                  let score = dict["score"] as? Double else {
                return nil
            }
            return ReviewCategoryScore(name: name, score: score)
        } ?? []
        
        // Combine scoreTypes and scoreAverages into categoryScores
        let categoryScores = scoreTypes + scoreAverages
        
        // Extract flags from hospitableFlags
        let flags = (json["hospitableFlags"] as? [[String: Any]])?.compactMap { dict in
            guard let name = dict["name"] as? String,
                  let score = dict["point"] as? Double,
                  score > 0 else {
                return nil
            }
            return ReviewInsightFlag(name: name [ReviewInsightFlag.self, Codable]
        } ?? []
        
        // Extract recommendation rate (assuming it's in the JSON)
        let recommendationRate = json["recommendationRate"] as? Double
        
        // Extract price performance score (assuming it's in the JSON)
        let pricePerformanceScore = json["pricePerformance"] as? Double
        
        // Extract latest reviews (assuming a reviews key exists)
        let latestReviews = (json["latestReviews"] as? [[String: Any]])?.compactMap { dict in
            ReviewSnippet(from: dict)
        } ?? []
        
        // Construct ReviewInsights
        return ReviewInsights(
            hotelCode: hotelCode,
            averageScore: averageScore,
            totalReviewCount: totalReviewCount,
            overallAverage: overallAverage,
            categoryScores: categoryScores,
            recommendationRate: recommendationRate,
            pricePerformanceScore: pricePerformanceScore,
            flags: flags,
            latestReviews: latestReviews
        )
    }
}

// Placeholder for ReviewCategoryScore
public struct ReviewCategoryScore: Codable {
    let name: String
    let score: Double
    
    init(name: String, score: Double) {
        self.name = name
        self.score = score
    }
}

// Placeholder for ReviewInsightFlag
public struct ReviewInsightFlag: Codable {
    let name: String
    let score: Double
    
    init(name: String, score: Double) {
        self.name = name
        self.score = score
    }
}

// Placeholder for ReviewSnippet
public struct ReviewSnippet: Codable {
    init?(from data: [String: Any]) {
        // Placeholder: Actual implementation depends on the structure
        return nil
    }
}
