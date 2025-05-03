//
//  ReviewInsightProvider.swift
//  CoreMCPKit
//
//  Created by İlker İsa Mercan on 2.05.2025.
//

import Foundation

/// Protocol to fetch processed review insights for a given hotel.
public protocol ReviewInsightProviding {
    func fetchInsights(for hotelCode: String) async throws -> ReviewInsights
}

/// Default implementation that fetches raw hotel review data and parses it into structured insights.
public final class ReviewInsightProvider: ReviewInsightProviding {
    private let parser: ReviewInsightParsing
    private let service: EtsHotelServiceProvider
    
    /// Initializes the provider with custom or default parser and API service.
    public init(
        parser: ReviewInsightParsing = ReviewInsightParser(),
        service: EtsHotelServiceProvider = EtsHotelService()
    ) {
        self.parser = parser
        self.service = service
    }
    
    /// Fetches and parses review insights for the specified hotel code.
    /// - Parameter hotelCode: Vendor-specific hotel code (e.g., "CLVOBE").
    /// - Returns: Parsed `ReviewInsights` object.
    public func fetchInsights(for hotelCode: String) async throws -> ReviewInsights {
        let raw = try await service.fetchHotelReviews(for: hotelCode, offset: 0)
        return try parser.parse(from: raw, hotelCode: hotelCode)
    }
}
