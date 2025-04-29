//
//  SocialProofContextProvider.swift
//  CoreMCPKit
//
//  Created by İlker İsa Mercan on 29.04.2025.
//


import Foundation

// MARK: - Context Provider (MCPContextProvider)

public final class SocialProofContextProvider: MCPContextProvider {
    // Dependencies
    private let provider: SocialProofExtractorProtocol
    private let preferenceExtractor: UserPreferencesExtractorProtocol
    private let etsService: EtsHotelServiceProvider
    
    // State
    public var selectedHotelUrl: String? // Kullanıcı seçimiyle dışarıdan set edilecek.
    
    // MCP Context Type
    public var contextType: String { "social_proof" }
    
    // MARK: - Init
    public init(
        provider: SocialProofExtractorProtocol,
        preferenceExtractor: UserPreferencesExtractorProtocol,
        etsService: EtsHotelServiceProvider
    ) {
        self.provider = provider
        self.preferenceExtractor = preferenceExtractor
        self.etsService = etsService
    }
    
    // MARK: - Provide Context
    public func provideContext(for prompt: String) async throws -> [String: Any] {
        guard let hotelUrl = selectedHotelUrl else {
            print("⚠️ SocialProofContextProvider: No selected hotel URL.")
            return [:]
        }
        
        // 1. Hotel Yorumlarını Çek
        let reviews = try await etsService.fetchComments(for: hotelUrl)
        print("✅ Fetched Hotel Reviews: \(reviews.count) reviews")
        
        // 2. Kullanıcı Promptundan Tercihleri Çek
        let preferences = try await preferenceExtractor.extractPreferences(from: prompt)
        print("✅ Extracted Preferences: \(preferences)")
        
        // 3. Social Proof Verisi Üret
        let socialProof = try await provider.fetchSocialProof(for: hotelUrl, reviews: reviews, userPreferences: preferences)
        
        // 4. JSON Serialize Et
        let encodedData = try JSONEncoder().encode(socialProof)
        let json = try JSONSerialization.jsonObject(with: encodedData) as? [String: Any] ?? [:]
        
        return [
            "type": contextType,
            "data": json
        ]
    }
}
