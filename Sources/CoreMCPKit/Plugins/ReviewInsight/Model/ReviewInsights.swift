//
//  ReviewInsights.swift
//  CoreMCPKit
//
//  Created by İlker İsa Mercan on 2.05.2025.
//

import Foundation

public struct ReviewInsights: Codable {
    public var hotelCode: String?
    /// Average review score. Note: This score is typically out of 100.
    public let averageScore: Double?
    
    public let totalReviewCount: Int?
    public let overallAverage: ReviewCategoryScore?
    public let categoryScores: [ReviewCategoryScore]?
    public let recommendationRate: Double?
    public let pricePerformanceScore: Double?
    public let flags: [ReviewInsightFlag]?
    public let latestReviews: [ReviewSnippet]?
    
    public init(
        hotelCode: String? = nil,
        averageScore: Double? = nil,
        totalReviewCount: Int? = nil,
        overallAverage: ReviewCategoryScore? = nil,
        categoryScores: [ReviewCategoryScore]? = nil,
        recommendationRate: Double? = nil,
        pricePerformanceScore: Double? = nil,
        flags: [ReviewInsightFlag]? = nil,
        latestReviews: [ReviewSnippet]? = nil
    ) {
        self.hotelCode = hotelCode
        self.averageScore = averageScore
        self.totalReviewCount = totalReviewCount
        self.categoryScores = categoryScores
        self.recommendationRate = recommendationRate
        self.pricePerformanceScore = pricePerformanceScore
        self.flags = flags
        self.latestReviews = latestReviews
        self.overallAverage = overallAverage
    }
}
