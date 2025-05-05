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
    private let extractor: ReviewInsightExtractorProtocol
    private let service: EtsHotelServiceProvider
    
    /// Initializes the provider with custom or default parser and API service.
    public init(
        extractor: ReviewInsightExtractorProtocol,
        service: EtsHotelServiceProvider = EtsHotelService()
    ) {
        
        self.extractor = extractor
        self.service = service
    }
    
    /// Fetches and parses review insights for the specified hotel code.
    /// - Parameter hotelCode: Vendor-specific hotel code (e.g., "CLVOBE").
    /// - Returns: Parsed `ReviewInsights` object.
    public func fetchInsights(for hotelCode: String) async throws -> ReviewInsights {
        let raw = try await service.fetchHotelReviews(for: hotelCode, offset: 0)
        
        print(raw)
        let baseReviews = [
            "Otel çok temizdi, personel güler yüzlüydü.",
            "Yemekler harikaydı ama odalar biraz küçüktü.",
            "Konum çok merkeziydi, sahile çok yakındı.",
            "Wi-Fi biraz yavaştı ama genel olarak memnun kaldım.",
            "Havuz alanı çok geniş ve temizdi, çocuklar çok eğlendi.",
            "Kahvaltı açık büfe ve çok çeşitliydi.",
            "Fiyat/performans açısından çok iyi bir oteldi.",
            "Klima çalışmıyordu, biraz sorun yaşadık.",
            "Personel çözüm odaklıydı, sorunları hızlıca çözdüler.",
            "Deniz manzaralı odam harikaydı, tekrar gelirim."
        ]
        let fakeReviews = (0..<30).map { _ in baseReviews.randomElement()! }
        
        
        return try await extractor.fetchReviewInsights(for: hotelCode, reviews: fakeReviews)
    }
}
